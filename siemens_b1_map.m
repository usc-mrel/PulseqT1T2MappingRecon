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

dataset_path = 'B1MAPTESTS220914';

full_dset_path = fullfile(storage_path, dataset_path);

dicomBrowser(full_dset_path);

as(double(V)/800, 'title', 'B1_map', 'colormap', 'turbo')

% B1_vials = [0.98, 1.02, 1, 0.94, 0.96, 0.97, 0.95, 0.93, 0.87, 0.78, 0.71, 0.7, 0.59, 0.51];
% 
% figure; plot(B1_vials, '*');
% xlabel('Vials');
% ylabel('Fractional B1');
% ylim([0.5, 1.1])
% xlim([1, 14])