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

Model = b1_afi;

% if ~isfile(qMRLab_prot_path)
%      % FlipAngle is a vector of [1X1]
%     Model.Prot.Alpha.Mat = FlipAngle;
% 
%     Model = Custom_OptionsGUI(Model);
% end

% Model = Model.loadObj(qMRLab_prot_path);
TR1 = 20;
TR2 = 100;
Model.Prot.Sequence.Mat = [ FlipAngle TR1 TR2];
%          |- b1_dam object needs 3 data input(s) to be assigned:
%          |-   SFalpha
%          |-   SF2alpha
%          |-   Mask

b1_data = struct();
b1_data.AFIData1 = double(D(:,:,:,1));
b1_data.AFIData2 = double(D(:,:,:,2));
% b1_data.Mask     = union_mask;

B1map_struct = FitData(b1_data,Model,0);
% qMRshowOutput(B1map_struct,b1_data,Model);


save(fullfile("input_data", filename), "B1map_struct", '-append');
