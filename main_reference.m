%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Bilal Tasdelen
% Description: Runs the whole pipeline for a given MRD file for single echo
% references.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% File Name
filename    = 'meas_MID00196_FID52882_IR_SE_TI_4500';
meas_type   = 't1map';     % 't1map', 't2map', 'b1map'

%% Convert MRD to mat
data_folder = '221109_array1_nih';
MIDs = [22:60];       % Give TE or TI series as an MID list.
single_echo_mrd2mat4mapping;

%% Select vials and slice to map

vialset = 'MnCl2';      % 'NiCl2', 'MnCl2' 
slc = 1;                % Slice for 3D acquisitions
nrots =  0;             % Number of times the phantom needs to be rotated for correct vial ordering.
erode_px = 1;           % Number of pixels to erode for tighter vial mask
flipimlr = false;
Preproc4Mapping;

%% Do the mapping

if strcmp(meas_type, 't2map')
    main_t2_sese;

elseif strcmp(meas_type, 'b1map')
    
    qMRLab_prot_filename = 'b1_dam.qmrlab.mat';
    FlipAngle = 30;

    main_b1map;

elseif strcmp(meas_type, 't1map')
    main_t1_irse;
end

%% Do the analysis
% ref_dir = '20221028_161025_meas_MID00293_FID04562_pulseq_T2';
if strcmp(meas_type, 't2map')
    NistPhantomT2ROIAnalysis;

elseif strcmp(meas_type, 'b1map')
    NistPhantomB1ROIAnalysis;

elseif strcmp(meas_type, 't1map')
    NistPhantomT1ROIAnalysis;
end
