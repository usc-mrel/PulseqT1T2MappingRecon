%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Bilal Tasdelen
% Description: Runs the whole pipeline for a given MRD file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% File Name
filename    = 'meas_MID00838_FID54559_pulseq3D_VFA_T1map_TR30_largespoilers';
meas_type   = 't1map';     % 't1map', 't2map', 'b1map'

%% Convert MRD to mat
data_folder = '221201_b1_debug';
ksp_filter  = true;
interpX     = 1; % Resolution interpolation coefficient (use for matching B1 map resolution to T1 maps.)
mrd2mat4mapping;

%% Select vials and slice to map

vialset = 'NiCl2';      % 'NiCl2', 'MnCl2' 
slc = 34:37;               % Slice for 3D acquisitions
nrots = 0;              % Number of times the phantom needs to be rotated for correct vial ordering.
erode_px = 1;           % Number of pixels to erode for tighter vial mask
edge_threshold = 0.02;     % Threshold for edge detection before auto segmentation.
flipimlr = false;
Preproc4Mapping;

%% Do the mapping

if strcmp(meas_type, 't2map')
    main_t2map_lsq;

elseif strcmp(meas_type, 'b1map')
    
    qMRLab_prot_filename = 'b1_dam.qmrlab.mat';
    FlipAngle = 30;

%     main_b1map_afi;
    main_b1map;


elseif strcmp(meas_type, 't1map')
    FlipAngle = [1.0, 1.7627, 3.1072, 5.4772, 9.6549, 17.019, 30.0];
    
    use_b1map = true;
    b1map_filename = 'meas_MID00832_FID54553_pulseq3D_AFI40_largespoilers_phi39_novirtrf_3ax';

    qMRLab_prot_filename = '221015_vfa_t1.qmrlab.mat';

    main_t1map;
end

%% Do the analysis
ref_dir = 'meas_MID00244_FID52930_IR_SE_TI_4500';
% ref_dir = 'zhibo_ref';


if strcmp(meas_type, 't2map') || strcmp(meas_type, 't1map')
    NistPhantomROIAnalysis;
elseif strcmp(meas_type, 'b1map')
    NistPhantomB1ROIAnalysis;
end
