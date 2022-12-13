addpath(genpath('./src'))

qMRLab_prot_dir = 'qMRLabProtocols';

if ~exist('filename', 'var')
    filename = "meas_MID00040_FID08027_ir_se_ti4500";
end
%% Load data and fill headers
load(fullfile("input_data", filename))

%% Setup qMRLab model
% qMRLab_prot_path = fullfile(qMRLab_prot_dir, qMRLab_prot_filename);

Model = inversion_recovery;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.IRData.Mat = img_header.sequenceParameters.TI';
Model.Prot.TimingTable.Mat = img_header.sequenceParameters.TR;
% Model.voxelwise = 1;
% if ~isfile(qMRLab_prot_path)
%     Model = Custom_OptionsGUI(Model);
% end

% Model = Model.loadObj(qMRLab_prot_path);

%          |- vfa_t1 object needs 3 data input(s) to be assigned:
%          |-   VFAData
%          |-   B1map
%          |-   Mask

T1map_struct = struct();
% VFAData.nii.gz contains [128  128    1    N] data.
T1map_struct.IRData = double(D(:,:,1,:));
% B1map.nii.gz contains [128  128] data.

% Mask.nii.gz contains [128  128] data.
T1map_struct.Mask = union_mask;
 
FitResults = FitData(T1map_struct,Model,0);
% FitResults = Model.fit(T2map_struct);
% qMRshowOutput(FitResults,data,Model);

T1 = FitResults.T1*1e-3; % [ms] -> [s]

save(fullfile("input_data", filename), 'FitResults', "T1", '-append');



