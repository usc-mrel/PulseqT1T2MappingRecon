addpath(genpath('./thirdparty'))
addpath(genpath('./utils'))

%% Load Data
% storage_path = '/Volumes/Macintosh HD - Data/MRI_DATA/';
storage_path = '/mnt/LIN_DATA/MRI_DATA/';

dataset_path = 'PST2MAP_220823/PULSEQNIST_22_08_21-18_11_23-DST-1_3_12_2_1107_5_2_18_41185/BILAL_PULSEQ_20220823_170149_888000/';
% series_path = '/PULSEQ_MNCLT2MAP_0003/';
series_path = '/PULSEQ_NICLT2MAP_0002/';


full_path = fullfile(storage_path, dataset_path, series_path);
[par, img] = dicomr(full_path);

%   Load MRI data and predefined options structure
load('t2_mese_rfinfo.mat')

vialset = 'NiCl2'; % 'NiCl2', 'MnCl2'

Neco = 32;

frame_txt = cell(1,Neco);
echotimes = (1:Neco)*15; % [ms]

for eco_i=1:Neco
    frame_txt{eco_i} = sprintf('TE=%.0f [ms]', echotimes(eco_i));
end


img = reshape(img, [128, 128, 1, Neco]);

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

[T2,B1,amp, opt] = StimFitImgPulseq(img,opt);


save(sprintf('T2map_out/%s_StimFit.mat', vialset), "T2", "B1", "amp", "opt")
