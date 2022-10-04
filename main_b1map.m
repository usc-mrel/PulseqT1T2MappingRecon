addpath(genpath('./thirdparty'))
addpath(genpath('./utils'))

% ================
%   USER INPUTS
% ================
if ismac
    storage_path = '/Volumes/WD/MRI_DATA';
    % dataset_path = '/Volumes/Macintosh HD - Data/MRI_DATA/';
elseif isunix
%     storage_path = '/mnt/LIN_DATA/MRI_DATA/';
    storage_path = '/run/media/bilal/WD/MRI_DATA';
end

dataset_path = 'B1SATTEST220910';
series_path = 'PULSEQ3D_B1MAP_TR0_05_15UT_0015';

% Recursively complete annoying dicom single folders till the series are
% found.
full_dset_path = fullfile(storage_path, dataset_path);

dlist = struct;
cont = 1;
while cont
    dlist = dir(full_dset_path);
    dlist = dlist([dlist.isdir]);
    dlist = dlist(3:end);

    if length(dlist) == 1
        full_dset_path = fullfile(full_dset_path, dlist.name);
    else
        cont = 0;
    end
end


full_path = fullfile(full_dset_path, series_path);

[par, img] = dicomread2(full_path);

[Nx, Ny, Nz] = size(img);

Nfa = 2;
Nz = Nz/2;

img = reshape(img, [Nx Ny Nz Nfa]);

FlipAngle=30; %par.FlipAngle;

%% Setup qMRLab model

Model = b1_dam;
% FlipAngle is a vector of [1X1]
Model.Prot.Alpha.Mat = FlipAngle;

% Model = Custom_OptionsGUI(Model);
Model = Model.loadObj('qMRLabProtocols/b1_dam.qmrlab.mat');
%          |- b1_dam object needs 3 data input(s) to be assigned:
%          |-   SFalpha
%          |-   SF2alpha
%          |-   Mask

data = struct();
% SFalpha.nii.gz contains [64  64] data.
data.SFalpha=double(img(:,:,:,1));
% SF2alpha.nii.gz contains [64  64] data.
data.SF2alpha=double(img(:,:,:,2));
data.Mask = data.SFalpha > 0;

FitResults = FitData(data,Model,0);
% qMRshowOutput(FitResults,data,Model);
%% Double angle

slcs = 6:25;

% s1 = img(:,:,:,1); %30
% s2 = img(:,:,:,2); %60
% 
% mask = s1 > 40;
% 
% im_rat = s2./(2*s1);
% im_rat(~mask) = 0;
% B1map_interp1 = rad2deg(acos(im_rat));


zlocs = 4*((1:Nz)-Nz/2);

frame_txt = cell(1,Nz);

for z_i=1:Nz
    frame_txt{z_i} = sprintf('Slice Location=%.0f', zlocs(z_i));
end

% B1map_raw = (B1map_interp1.*mask)./FlipAngle;
B1map_raw = FitResults.B1map_raw;
as(B1map_raw(:,:,slcs), 'title', 'B1map_raw', 'colormap', 'turbo', 'imageText', frame_txt(slcs))
asObjs(end).showColorbar(true)
asObjs(end).window.overwriteSliderLimits(0.5, 2)

B1map_scl = B1map_raw.*FlipAngle;
B1map_scl(isnan(B1map_scl)) = 0;
%% Interpolate and save
% slice_thickness = 8e-3;
% slice_pos = 44e-3 + (-Nz/2:Nz/2-0.5)*slice_thickness;
os_factor = 2;
Nxp = os_factor*Nx; Nyp = os_factor*Ny; Nzp = os_factor*Nz;

B1map_fft = hamming(Nx).*hamming(Ny).'.*fftmod3(B1map_scl)./(Nx*Ny*Nz);
B1map_fftpad = padarray(B1map_fft, (os_factor-1).*[Nx, Ny, Nz]./2, 0, "both").*(Nxp*Nyp*Nzp);
B1map_interp = abs(ifftmod3(B1map_fftpad));
B1map_interp = B1map_interp(:,:,:)./FlipAngle;

as(B1map_interp, 'title', 'B1map_raw', 'colormap', 'turbo')
asObjs(end).showColorbar(true)
asObjs(end).window.overwriteSliderLimits(0.5, 1.5)

save('B1map_out/b1map_TR005_220911', 'B1map_interp', 'B1map_raw')
