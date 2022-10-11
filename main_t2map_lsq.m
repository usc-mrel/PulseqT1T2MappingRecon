addpath(genpath('./src'))

%% Load Data
filename = "meas_MID00188_FID08175_pulseqT2_lower";

%   Load MRI data and predefined options structure
load('t2_mese_rfinfo.mat')

load(fullfile("input_data", filename))

[Nx, Ny, Neco] = size(D, [1 2 4]);

frame_txt = cell(1,Neco);
echotimes = (1:Neco)*img_header.sequenceParameters.TE; % [ms]

for eco_i=1:Neco
    frame_txt{eco_i} = sprintf('TE=%.0f [ms]', echotimes(eco_i));
end



figtitle = sprintf('%s_ET_movie', vialset);
% as(flipud(squeeze(img)), 'title', figtitle, 'imageText', frame_txt)

% figure; montage(squeeze(img), 'DisplayRange', [], 'Indices', 1:2:32); title(sprintf('Echoes, %s', par.SeriesDescription), 'Interpreter', 'None')

% Fill opt struct
opt = StimFit_optset;

opt.mode = 's';
opt.Dz = [-0.3 0.3]; % [cm]
opt.Nz = 20;
opt.Nrf = length(rfe);
opt.esp = 15e-3; % [s]
opt.etl = 32;
% opt.T1 = @(T2) 1;

opt.debug = 1;
opt.th = 0;
opt.th_te = 1:3;
opt.FitType = 'lsq';

% Excitation
opt.RFe.path = "";
opt.RFe.RF = 1e4*rfe./(42.58e6*10);
opt.RFe.tau = t_rfe(end); % [s]
opt.RFe.G = Ge;
opt.RFe.phase = 0;
opt.RFe.angle = 90;
opt.RFe.ref = 1;

% Refocusing
opt.RFr.path = "";
opt.RFr.RF = 1e4*rfr./(42.58e6*10);
opt.RFr.tau = t_rfr(end); % [s]
opt.RFr.G = Gr;
opt.RFr.phase = 90;
opt.RFr.angle = 180;
opt.RFr.ref = 0;

% LSQ options

opt.lsq.Ncomp = 1;

opt.lsq.Icomp.X0   = [0.060 1e-1 0.99];      %   Starting point (1 x 3) [T2(s) amp(au) B1(fractional)]
opt.lsq.Icomp.XU   = [3.000 1e+3 1.00];      %   Upper bound (1 x 3)
opt.lsq.Icomp.XL   = [0.005 0.00 0.30];      %   Lower bound (1 x 3)

%%% FIT SINGLE VOXEL %%%
% S = squeeze(img(70,69,1,:));
% opt.debug = 1;
% opt.FitType = 'lsq';
% [T2,B1,amp] = StimFit(S,opt);


%%% FIT ENTIRE IMAGE %%%

[T2,B1,amp, opt] = StimFitImgPulseq(D, opt);


save(sprintf('T2map_out/%s_StimFit.mat', vialset), "T2", "B1", "amp", "opt")
