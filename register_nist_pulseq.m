addpath(genpath('./thirdparty'))
addpath(genpath('./utils'))

% storage_path = '/Volumes/Macintosh HD - Data/MRI_DATA/';
% storage_path = '/mnt/LIN_DATA/MRI_DATA/';
if ismac
    storage_path = '/Volumes/WD/MRI_DATA/';
elseif isunix
    storage_path = '/run/media/bilal/WD/MRI_DATA/';
end

dataset_path = 'PST1MAPBOTH220826/PULSEQNIST_22_08_21-18_11_23-DST-1_3_12_2_1107_5_2_18_41185/BILAL_PULSEQ_20220826_201628_976000/';
% series_path = '/PULSEQ_T1MAPMNCL2_0006/';
series_path = '/PULSEQ3D_BOTHT1MAP_0009/';

full_path = fullfile(storage_path, dataset_path, series_path);

% R = read_dicom_ir(full_path);
[par, img] = dicomr(full_path);
Nfa = 7;
[Nx, Ny, Nz] = size(img);
Nz = Nz/Nfa;
img = reshape(img, [Nx, Ny, Nz, Nfa]);

vialset = 'MnCl2'; % 'NiCl2', 'MnCl2'
% img2 = squeeze(mean(img, 3));
% img2 = squeeze(img(:,:,3,:));
if strcmp(vialset, 'MnCl2')
    slc = 20; % MnCl2 [T2 array]
    itype = 2;
elseif strcmp(vialset, 'NiCl2')
    slc = 40; % NiCl2 [T1 array]
    itype = 1;
end

D = permute(squeeze(img(:,:,slc,:)), [1 2 3]);
P = register_phantom2d(D, 0.3, itype);

%% Plot rois
nmax = size(P.Y,1);
mmax = size(P.Y,2);

dx = P.dx
dy = P.dy
phi = P.phi;
phi_degrees = phi * 180/pi

roi_centers = P.roi_centers_geo
roi_radii = P.roi_radii_geo


ifplot = 1;

if( ifplot == 1 )

    figure;
    subplot(221)
    imagesc(double(P.Y))
    colormap(jet)
    colorbar
    title('Image for registration')
    axis image;
    
    subplot(222)
    imagesc(P.Za)
    colormap(jet)
    colorbar
    title('Edges')
    axis image;
    
    subplot(223)
    
    imagesc(P.phantom_mask_init)
    colormap(jet)
    colorbar
    title('Phantom mask, reference')
    axis image;
    
    subplot(224)
    imagesc(P.phantom_mask_match)
    colormap(jet)
    colorbar
    title('Phantom mask, matched')
    axis image;
    
    figure;
    subplot(221)
    imagesc(P.phantom_mask_match .* P.Y )
    colormap(jet)
    colorbar
    title('Image, masked')
    axis image;
    
    subplot(222);
    imagesc(P.phantom_mask_match .* P.Za )
    colormap(jet)
    colorbar
    title('Edges, masked')
    axis image;
    
    % extract all regions
    c = zeros(nmax);
    for id = 1:14
    d = cmask(nmax,P.roi_radii_geo(id)*1.2,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + d .* P.Za;
    end
    
    subplot(223)

    imagesc(c)
    colormap(jet)
    colorbar
    title('Edges (detected ROIs, tight)')
    axis image;
    
    % extract all regions
    c = zeros(nmax);
    for id = 1:14
    b = cmask(nmax,P.mask_radius,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + b .* P.Y;
    end
    
    subplot(224)
    imagesc(c)
    colormap(jet)
    colorbar
    title('Image (detected ROIs)')
    axis image;
    
    % extract all regions
    c = zeros(nmax);
    for id = 1:14
    b = cmask(nmax,P.roi_radii_geo(id),...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
    c = c + b .* P.Y;
    end
    
    figure;
    imagesc(c)
    title(series_path)
    colormap(jet)
    colorbar
    title('Image (detected ROIs, tight)')
    axis image;
 
end