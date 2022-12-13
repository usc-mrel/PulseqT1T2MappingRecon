addpath(genpath('./src'))

qMRLab_prot_dir = 'qMRLabProtocols';

if ~exist('qMRLab_prot_filename', 'var')
    qMRLab_prot_filename = '221015_vfa_t1.qmrlab.mat';
end
if ~exist('filename', 'var')
    filename = "meas_MID00118_FID47426_pulseq3D_vfa_sinc_8+4_fisp";
end
if ~exist('FlipAngle', 'var')
    FlipAngle = [1.0, 1.7627, 3.1072, 5.4772, 9.6549, 17.019, 30.0];
end
if ~exist('use_b1map', 'var')
    use_b1map = false;
end
if ~exist('b1map_filename', 'var')
    b1map_filename = 'meas_MID00105_FID47418_pulseq3D_DAMB1_wRESET';
end
%% Load data and fill headers
load(fullfile("input_data", filename))
TR = img_header.sequenceParameters.TR*1e-3;

b1mat = load(fullfile("input_data", b1map_filename));

%% Setup qMRLab model
qMRLab_prot_path = fullfile(qMRLab_prot_dir, qMRLab_prot_filename);

Model = vfa_t1;
% FlipAngle is a vector of [NX1]
% TR is a vector of [NX1]
Model.Prot.VFAData.Mat = [FlipAngle' repelem(TR, length(FlipAngle))'];

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
T1map_struct.VFAData=double(D);
% B1map.nii.gz contains [128  128] data.
if use_b1map
    B1map = b1mat.B1map_struct.B1map_raw;
    sz_diff = (size(D, 1) - size(B1map, 1))/2;
    B1map = abs(fftmod2(padarray(ifftmod2(B1map), [sz_diff, sz_diff], "both")));
    T1map_struct.B1map = B1map;
end
% Mask.nii.gz contains [128  128] data.
% T1map_struct.Mask=double(sum(T1map_struct.VFAData, 4) > 1e-4).*union_mask;
T1map_struct.Mask=union_mask;

% FitResults = FitData(T1map_struct,Model,0);
FitResults = Model.fit(T1map_struct);
% qMRshowOutput(FitResults,data,Model);

T1 = FitResults.T1;
M  = FitResults.M0;

save(fullfile("input_data", filename), "T1", "M", '-append');



