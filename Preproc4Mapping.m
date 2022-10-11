%% Inputs

vialset = 'MnCl2'; % 'NiCl2', 'MnCl2' 
meas_type = 'mcse'; % 'vfa', 'mcse', 'b1map'
slc = 5; % Slice for 3D acquisitions

filename = "meas_MID00188_FID08175_pulseqT2_lower";

%% Load data
addpath(genpath('src/'))

load(fullfile("input_data", filename))

[Nx, Ny, Nz, Neco] = size(image, [1 2 3 6]);

if strcmp(meas_type, 'mcse') % disregard if 2D acq
    slc = 1;
end

img = rot90(reshape(image, [Nx, Ny, Nz, Neco]));

% img2 = squeeze(mean(img, 3));
% img2 = squeeze(img(:,:,3,:));
if strcmp(vialset, 'MnCl2')
    itype = 2;
elseif strcmp(vialset, 'NiCl2')
    itype = 1;
end

D = img(:,:,slc,:);
P = register_phantom2d(D, 0.1, itype);

%% Find and save vial masks
nvial = 14;
[nmax, mmax] = size(P.Y, [1 2]);

% extract all regions
vial_masks = zeros(nmax, mmax, nvial);
for id = 1:nvial
    vial_masks(:,:,id) = cmask(nmax,P.roi_radii_geo(id)-1,...
              P.roi_centers_geo(id,1),P.roi_centers_geo(id,2)); % individual vial masks
end
union_mask = max(vial_masks, [], 3); % all vial masks

save(fullfile("input_data", filename), 'vial_masks', "union_mask", "slc", "vialset", "D" ,'-append');

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
    title(filename)
    colormap(jet)
    colorbar
    title('Image (detected ROIs, tight)')
    axis image;
 
end