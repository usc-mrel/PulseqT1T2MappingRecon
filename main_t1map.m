addpath(genpath('./thirdparty'))
addpath(genpath('./utils'))

if ismac
    storage_path = '/Volumes/WD/MRI_DATA';
    % dataset_path = '/Volumes/Macintosh HD - Data/MRI_DATA/';
elseif isunix
%     storage_path = '/mnt/LIN_DATA/MRI_DATA/';
    storage_path = '/run/media/bilal/WD/MRI_DATA';
end

dataset_path = 'PST1MAPBOTH220826/PULSEQNIST_22_08_21-18_11_23-DST-1_3_12_2_1107_5_2_18_41185/BILAL_PULSEQ_20220826_201628_976000/';
% series_path = '/PULSEQ_T1MAPMNCL2_0006/';
series_path = '/PULSEQ3D_BOTHT1MAP_0009/';
FlipAngle = [1.0, 1.7627, 3.1072, 5.4772, 9.6549, 17.019, 30.0];
TR = 14e-3;

use_b1map = true;
b1map_filename = 'b1map_220828';

full_path = fullfile(storage_path, dataset_path, series_path);
[par, img] = dicomr(full_path);
Nfa = 7;
[Nx, Ny, Nz] = size(img);
Nz = Nz/Nfa;
img = reshape(img, [Nx, Ny, Nz, Nfa]);

load(b1map_filename)

frame_txt = cell(1,Nfa);

for fa_i=1:length(FlipAngle)
    frame_txt{fa_i} = sprintf('FA=%.2f', FlipAngle(fa_i));
end

% as(img, 'callback', asCb)

%% Process
vialset = 'NiCl2'; % 'NiCl2', 'MnCl2'
% img2 = squeeze(mean(img, 3));
% img2 = squeeze(img(:,:,3,:));
if strcmp(vialset, 'MnCl2')
    slc = 20; % MnCl2
elseif strcmp(vialset, 'NiCl2')
    slc = 40; % NiCl2
end

%% Setup qMRLab model

Model = vfa_t1;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.VFAData.Mat = [FlipAngle' repelem(TR, length(FlipAngle))'];

% Model = Custom_OptionsGUI(Model);
Model = Model.loadObj('qMRLabProtocols/vfa_t1.qmrlab.mat');

%          |- vfa_t1 object needs 3 data input(s) to be assigned:
%          |-   VFAData
%          |-   B1map
%          |-   Mask

data = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
data.VFAData=double(img(:,:,slc,:));
% B1map.nii.gz contains [128  128] data.
data.B1map=double(b1map(:,:,slc,:));
% Mask.nii.gz contains [128  128] data.
data.Mask=~double(sum(data.VFAData >= 25,4) < 3);
 
FitResults = FitData(data,Model,0);
qMRshowOutput(FitResults,data,Model);

T1 = FitResults.T1;
M = FitResults.M0;

save(sprintf('T1map_out/%s_T1Fit', vialset), 'M', 'T1')

%%
figtitle = sprintf('%s_FA_movie', vialset);
img2 = img(:,:,slc,:); 
b1slc = b1map(:,:,slc,:);
as(squeeze(img2), 'title', figtitle, 'imageText', frame_txt)

opt.FA = FlipAngle;
opt.tr = TR;
opt.class = 'double';

if use_b1map
    opt.B1 = b1slc;
end

Npixel = Nx*Ny;
imv = reshape(img2, Npixel, Nfa);

Threshold = 15; 
for p=1:Npixel
    s = imv(p,:);
    if sum(s>=Threshold) < 3
        imv(p,:) = 0;
    end
end
img2 = reshape(imv, Nx, Ny,1, Nfa);

[T1,M,R2, failureMask] = iDESPOT1(img2,opt);
% T1(T1 > 3) = 3;
%   Converts images into T1 and Mo maps
%   
%   opt: options structure with fields
%       FA: flip angle (degrees)
%       tr: repetition time (s)
%       B1: transit field scale (fraction)
%       class: specifies 'single' or 'double'

save(sprintf('T1map_out/%s_T1Fit', vialset), 'M', 'T1')

%% Do the fitting

% % Do the fitting
% Npixel = Nx*Ny;
% imv = abs(reshape(img2, Npixel, Nfa));
% myspgr = @(x) x(1).*sind(alpha).*(1-exp(-TR/x(2)))./(1-cosd(alpha).*exp(-TR/x(2)));
% 
% T1 = zeros(Npixel,1); M = T1;
% 
% Threshold = 10; 
% for p=1:Npixel
%     y = imv(p,:);
%     if sum(y>=Threshold) < 3
%         continue;
%     end
%     [xx, yy] = ind2sub([Nx, Ny], p);
%     
%     myobj = @(x) sum((y-myspgr(x)).^2);
%     f = fmincon(myobj, [10, 1], [], [], [], [], [0,0], [max(img2, [], 'all'), 5]);
%     T1(p) = f(2);
%     M(p) = f(1);
% 
% end
% T1 = reshape(T1, Nx, Ny);
% M = reshape(M, Nx, Ny);

% save('T1FitResultsNoDummy', 'M', 'T1')


