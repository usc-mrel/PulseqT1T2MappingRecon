addpath(genpath('./src'))

qMRLab_prot_dir = 'qMRLabProtocols';

if ~exist('qMRLab_prot_filename', 'var')
    qMRLab_prot_filename = '221015_vfa_t1.qmrlab.mat';
end
if ~exist('filename', 'var')
    filename = "meas_MID00072_FID08059_se_te480";
end
%% Load data and fill headers
load(fullfile("input_data", filename))

%% Setup qMRLab model
% qMRLab_prot_path = fullfile(qMRLab_prot_dir, qMRLab_prot_filename);

Model = mono_t2;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.SEdata.Mat=img_header.sequenceParameters.TE'*1e-3;
Model.options.OffsetTerm = false;
Model.options.FitType = 'Exponential'; % 'Exponential', 'Linear'
Model.options.DropFirstEcho = false;
Model.lb = [1 1];
Model.ub = [2e3 10000];
% Model.voxelwise = 1;
% if ~isfile(qMRLab_prot_path)
%     Model = Custom_OptionsGUI(Model);
% end

% Model = Model.loadObj(qMRLab_prot_path);

%          |- vfa_t1 object needs 3 data input(s) to be assigned:
%          |-   VFAData
%          |-   B1map
%          |-   Mask

T2map_struct = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
T2map_struct.SEdata=double(D(:,:,1,:));
% B1map.nii.gz contains [128  128] data.

% Mask.nii.gz contains [128  128] data.
T2map_struct.Mask = union_mask;
 
FitResults = FitData(T2map_struct,Model,0);
% FitResults = Model.fit(T2map_struct);
% qMRshowOutput(FitResults,data,Model);

T2 = FitResults.T2;
M  = FitResults.M0;

save(fullfile("input_data", filename), 'FitResults', "T2", "M", '-append');



