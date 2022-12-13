addpath(genpath('./src'))

% ================
%   USER INPUTS
% ================
qMRLab_prot_dir = 'qMRLabProtocols';

if ~exist('qMRLab_prot_filename', 'var')
    qMRLab_prot_filename = 'b1_dam.qmrlab.mat';
end
if ~exist('filename', 'var')
    filename = "meas_MID00115_FID47423_pulseq3D_DAMB1_noRESET_lowres";
end
if ~exist('FlipAngle', 'var')
    FlipAngle = 30;
end

%%  Load MRI data and predefined options structure
load(fullfile("input_data", filename))

%% Setup qMRLab model
qMRLab_prot_path = fullfile(qMRLab_prot_dir, qMRLab_prot_filename);

Model = b1_dam;

if ~isfile(qMRLab_prot_path)
     % FlipAngle is a vector of [1X1]
    Model.Prot.Alpha.Mat = FlipAngle;

    Model = Custom_OptionsGUI(Model);
end

Model = Model.loadObj(qMRLab_prot_path);
Model.Prot.Alpha.Mat = FlipAngle;

%          |- b1_dam object needs 3 data input(s) to be assigned:
%          |-   SFalpha
%          |-   SF2alpha
%          |-   Mask

b1_data = struct();
b1_data.SFalpha  = double(D(:,:,:,1));
b1_data.SF2alpha = double(D(:,:,:,2));
% b1_data.Mask     = union_mask;

B1map_struct = FitData(b1_data,Model,0);
% qMRshowOutput(B1map_struct,b1_data,Model);
%% Double angle

% B1map_raw = FitResults.B1map_raw;
% as(B1map_raw, 'title', 'B1map_raw', 'colormap', 'turbo')
% asObjs(end).showColorbar(true)
% asObjs(end).window.overwriteSliderLimits(0.5, 1.5)

%% Interpolate and save
% slice_thickness = 8e-3;
% slice_pos = 44e-3 + (-Nz/2:Nz/2-0.5)*slice_thickness;
% os_factor = 2;
% Nxp = os_factor*Nx; Nyp = os_factor*Ny; Nzp = os_factor*Nz;
% 
% B1map_fft = hamming(Nx).*hamming(Ny).'.*fftmod3(B1map_scl)./(Nx*Ny*Nz);
% B1map_fftpad = padarray(B1map_fft, (os_factor-1).*[Nx, Ny, Nz]./2, 0, "both").*(Nxp*Nyp*Nzp);
% B1map_interp = abs(ifftmod3(B1map_fftpad));
% B1map_interp = B1map_interp(:,:,:)./FlipAngle;

% as(B1map_interp, 'title', 'B1map_raw', 'colormap', 'turbo')
% asObjs(end).showColorbar(true)
% asObjs(end).window.overwriteSliderLimits(0.5, 1.5)

save(fullfile("input_data", filename), "B1map_struct", '-append');
