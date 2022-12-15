%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Bilal Tasdelen
% Description: Prepares Siemens raw file for T1-T2 Mapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('src/'));

%% Inputs

if ~exist('data_folder', 'var')
    data_folder = '221015_vfa_debug';
end
if ~exist('filename', 'var')
    filename    = 'meas_MID00115_FID47423_pulseq3D_DAMB1_noRESET_lowres';
end
if ~exist('ksp_filter' ,'var')
    ksp_filter = true;
end
if ~exist('interpX' ,'var')
    interpX = 1;
end
%% Data paths
if ismac
    DATA_ROOT = '/Volumes/WD/MRI_DATA';
elseif isunix
    DATA_ROOT = '/run/media/bilal/WD/MRI_DATA/';
end


data_folder_path = fullfile(DATA_ROOT, data_folder);
raw_file_path    = fullfile(data_folder_path, 'raw', filename);

ismrmrd_data_fullpath = fullfile(data_folder_path, 'raw/h5', [filename '.h5']);
ismrmrd_noise_path    = fullfile(data_folder_path, 'raw/noise', ['noise_' filename, '.h5']);

pulseq_file = 'spiral2d_220418_1331.seq'; % TODO: Add automatic seq file loading

%% Config
is_pulseq = false; % TODO: Add automatic Pulseq detection
prewhiten = true;
%% Load MRD data

fprintf('Reading MRD raw data...')

dset = ismrmrd.Dataset(ismrmrd_data_fullpath, 'dataset');
img_header = ismrmrd.xml.deserialize(dset.readxml);
acq = dset.readAcquisition();
acq_header = acq.head;

fprintf(' Done.\n\n')

fprintf('Reading MRD calibration data...')
noise_dset = ismrmrd.Dataset(ismrmrd_noise_path, 'dataset');
raw_data_noise = noise_dset.readAcquisition();
noise_header = raw_data_noise.head;
fprintf(' Done.\n\n')

%% Get parameters from the header
discard = 0;

Ncha = acq_header.active_channels(1);
N = acq_header.number_of_samples(1);

Nrep = double(max(acq_header.idx.repetition)) + 1;
Navg = double(max(acq_header.idx.average)) + 1;
Neco = double(max(acq_header.idx.contrast)) + 1;
Nset = double(max(acq_header.idx.set)) + 1;

Neco = Nset; % WARNING; FOR PULSEQ, ECO DOES NOT WORK, SO WE USE SET

Nkx = img_header.encoding.encodedSpace.matrixSize.x; % number of readout samples in k-space
Nky = img_header.encoding.encodedSpace.matrixSize.y; % number of phase encodes in k-space
% Nkz = img_header.encoding.encodedSpace.matrixSize.z; % number of slice encodes in k-space
% Nx  = img_header.encoding.reconSpace.matrixSize.x;   % number of samples in image-space (RO)
% Ny  = img_header.encoding.reconSpace.matrixSize.y;   % number of samples in image-space (PE)
Nz  = img_header.encoding.reconSpace.matrixSize.z;   % number of samples in image-space (SL)
Nx = Nkx; % Either Pulseq or NX
Ny = Nky; % Either Pulseq or NX
Nkz = Nz; % Either Pulseq or NX

fov = [img_header.encoding.encodedSpace.fieldOfView_mm.x
       img_header.encoding.encodedSpace.fieldOfView_mm.y
       img_header.encoding.encodedSpace.fieldOfView_mm.z]*1e-3; % [m]


Npe  = double(max(acq_header.idx.kspace_encode_step_1)) + 1; % nr_interleaves for spiral imaging
Npar = double(max(acq_header.idx.kspace_encode_step_2)) + 1;
Nslc = double(max(acq_header.idx.slice)) + 1;

nr_slice_encodings = acq_header.idx.kspace_encode_step_2 + 1;

TE = img_header.sequenceParameters.TE*1e-3;

is_cartesian = strcmp(img_header.encoding.trajectory, 'cartesian'); % TODO: If pulseq, this info is incorrect.


%% Load noise
noise = get_noise(raw_data_noise);


%% Fill recon header
recon_header.Nx = Nx;
recon_header.Ny = Ny;
recon_header.Nz = Nz;
recon_header.Nc = Ncha;
recon_header.Nkz = Nkz;
recon_header.Nslc = Nslc;
recon_header.Nd = N-discard;
recon_header.Npe = Npe;
recon_header.pre_discard = discard+1;
recon_header.Neco = Neco;
recon_header.ADCDwellTime = acq_header.sample_time_us(1)*1e-6; % [s]
recon_header.fov = fov;
recon_header.is_cartesian = is_cartesian;
recon_header.is_pulseq = is_pulseq;
recon_header.prewhiten = prewhiten;
recon_header.ksp_filter = ksp_filter;

data = get_ksp(acq, acq_header, recon_header);

%% FFT and prewhiten the data

if is_cartesian
%     data_bart = reshape(data, [N, Npe, Npar, Ncha, 1, Neco]);
    if prewhiten
        data = bart('whiten', data, noise);
    end
    if ksp_filter
        ksp_filter_coeff = 0.4;
        data = data...
            .*tukeywin(Nx, ksp_filter_coeff)...
            .*tukeywin(Ny, ksp_filter_coeff)'...
            .*reshape(tukeywin(Nz, ksp_filter_coeff), [1,1,Nz]);
    end
    if interpX > 1
        sz_diff = [(Nx*interpX-Nx) (Ny*interpX-Ny) (Nz*interpX-Nz)]/2;
        data = padarray(data, sz_diff, "both");
        recon_header.Nx = size(data, 1);
        recon_header.Ny = size(data, 2);
        recon_header.Nz = size(data, 3);
    end
    if Npar > 1 % 3D sequence
        image = rssq(ifftmod3(data), 4); 
    else
        image = rssq(ifftmod2(data), 4);
    end
else
    warning("Not Cartesian, I'm out.")
    exit();
end

as(image, 'title', sprintf('Image %s', filename));

%% Format and save data for T1-T2 Mapping

save(sprintf('input_data/%s', filename), 'data', 'recon_header', 'acq_header', 'img_header', 'noise', 'noise_header', 'image')
