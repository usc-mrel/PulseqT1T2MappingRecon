if ~exist('filename', 'var')
    filename = 'meas_MID00255_FID47649_pulseq3D_SDAM_FA40';
end

out_dir = fullfile('B1map_out/', filename);

mkdir(out_dir)

load(fullfile("input_data", filename))
B1 = B1map_struct.B1map_raw;

vial_B1 = vial_masks.*B1;

nvial = 14;

mean_sort = zeros(nvial,1);
std_sort = zeros(nvial,1);
fid = fopen(fullfile(out_dir, 'stats.txt'), 'wt');
for v_i=1:nvial
    nzs = nonzeros(vial_B1(:,:,:,v_i));
    mean_sort(v_i) = mean(nzs, 'omitnan');
    std_sort(v_i) = std(nzs, 'omitnan');
    line = sprintf('Vial %i = %.3f ± %.3f\n', v_i, mean_sort(v_i), std_sort(v_i));
    fprintf(line)
    fprintf(fid, line);
end

%% 
Nslc = size(B1, 3);
for z_i=1:Nslc
    f = figure; imagesc(B1(:,:,z_i)); axis image; colormap turbo; colorbar;
    title(sprintf("Slice: %i, %s B1 map", z_i, recon_header.vialset))
    caxis([0.5 1.5])

    exportgraphics(gcf,fullfile(out_dir, sprintf('B1map_scl%i.eps', z_i)), 'ContentType','vector');
end
%%
figure; errorbar(1:nvial, mean_sort, std_sort,  '*', 'LineWidth',2);
ylim([0, 1.5])
xlabel('Vials')
ylabel('Estimated B1+ ratio')
title('B1+ vs. vial')
exportgraphics(gcf,fullfile(out_dir, 'B1_pervial.eps'), 'ContentType','vector');
