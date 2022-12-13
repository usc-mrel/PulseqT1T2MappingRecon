%% Inputs

if ~exist('vialset', 'var')
    vialset = 'MnCl2';      % 'NiCl2', 'MnCl2' 
end
if ~exist('meas_type', 'var')
    meas_type = 't1map';     % 't1map', 't2map', 'b1map'
end
if ~exist('slc', 'var')
    slc = 4;               % Slice for 3D acquisitions
end
if ~exist('nrots', 'var')
    nrots =  1;             % Number of times the phantom needs to be rotated for correct vial ordering.
end
if ~exist('erode_px', 'var')
    erode_px = 1;           % Number of pixels to erode for tighter vial masks.
end
if ~exist('edge_threshold', 'var')
    edge_threshold = 0.05;     % Threshold for edge detection before auto segmentation.
end
if ~exist('flipimlr', 'var')
    flipimlr = true;           % Whether or not to flip image in left right direction.
end
if ~exist('filename', 'var')
    filename = "meas_MID00115_FID47423_pulseq3D_DAMB1_noRESET_lowres";
end
%% Load data
addpath(genpath('src/'))

load(fullfile("input_data", filename))

[Nx, Ny, Nz, Neco] = size(image, [1 2 3 6]);

gscale = 1/(recon_header.fov(1)/double(recon_header.Nx)*1e3);

if Nz == 1 % disregard if 2D acq
    slc = 1;
end
recon_header.slc = slc;
recon_header.vialset = vialset;
recon_header.meas_type = meas_type;

img = rot90(reshape(image, [Nx, Ny, Nz, Neco]), nrots);

if flipimlr % Siemens convention shenaningas
    img = fliplr(img);
end

if Nz > 1 % disregard if 2D acq
%     img = mean(img(:,:,slc,:), 3);
    img = img(:,:,slc,:);
end

% img2 = squeeze(mean(img, 3));
% img2 = squeeze(img(:,:,3,:));
if strcmp(vialset, 'MnCl2')
    itype = 2;
elseif strcmp(vialset, 'NiCl2')
    itype = 1;
end

% D = img(:,:,1,:);
D = img;

nvial = 14;
Nslc = size(D, 3);

vial_masks = zeros(Nx, Ny, Nslc, nvial);
union_mask = zeros(Nx, Ny, Nslc);
for z_i=1:Nslc
    P = register_phantom2d(sum(D(:,:,z_i,:),4), edge_threshold, itype, gscale);
    
    %% Find and save vial masks
    
    % extract all regions
    minradii = min(P.roi_radii_geo);
    for id = 1:nvial
        vial_masks(:,:,z_i,id) = cmask(Nx, minradii-erode_px,...
                  P.roi_centers_geo(id,1),P.roi_centers_geo(id,2)); % individual vial masks
    end
    union_mask(:,:,z_i) = max(vial_masks(:,:,z_i,:), [], 4); % all vial masks
end
save(fullfile("input_data", filename), 'vial_masks', "union_mask", "recon_header", "D", '-append');

%% Plot rois


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
    c = zeros(Nx);
    for id = 1:14
    d = cmask(Nx,P.roi_radii_geo(id)*1.2,...
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
    c = zeros(Nx);
    for id = 1:14
    b = cmask(Nx,P.mask_radius,...
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
    c = zeros(Nx);
    for id = 1:14
        b = cmask(Nx,P.roi_radii_geo(id),...
                  P.roi_centers_geo(id,1),P.roi_centers_geo(id,2));
        c = c + b .* P.Y;
    end
    
    figure;
    imagesc(c)
    title(filename)
    colormap(jet)
    colorbar
    title('Image (detected ROIs, tight)')
    axis image;
 
end