addpath(genpath('src/'))

if ~exist('filename', 'var')
    filename = 'meas_MID00838_FID54559_pulseq3D_VFA_T1map_TR30_largespoilers';
%     filename = 'meas_MID00188_FID08175_pulseqT2_lower';

end

if ~exist('ref_dir', 'var')
    ref_dir = 'zhibo_ref';
end


%% Load data
load(fullfile("input_data", filename))

meas_type = recon_header.meas_type;

out_dir = fullfile(sprintf('%s_out/', meas_type), filename);
mkdir(out_dir)


switch meas_type
    case 't1map'
        vial_XX = vial_masks.*T1*1e3;
        meas_map = T1;
    case 't2map'
        vial_XX = vial_masks.*T2*1e3;
        meas_map = T2;
    otherwise
        error('Wrong measurement type. Must be t1map, t2map.')
end


nvial = 14;
mean_sort = zeros(nvial,1);
std_sort = zeros(nvial,1);
fid = fopen(fullfile(out_dir, 'stats.txt'), 'wt');
for v_i=1:nvial
    nzs = nonzeros(vial_XX(:,:,:,v_i));
    mean_sort(v_i) = mean(nzs, 'omitnan');
    std_sort(v_i) = std(nzs, 'omitnan');
    sline = sprintf('Vial %i = %.3f ± %.3f [ms]\n', v_i, mean_sort(v_i), std_sort(v_i));
    fprintf(sline)
    fprintf(fid, sline);
end

%% 
Nslc = size(vial_XX, 3);
for z_i=1:Nslc
    f = figure; imagesc(meas_map(:,:,z_i).*1e3); axis image; colormap turbo; colorbar;
    title(sprintf("Slice: %i, %s %s [ms]", z_i, recon_header.vialset, meas_type))
    % ax1 = gca;
    
    exportgraphics(gcf,fullfile(out_dir, sprintf('%s_scl%i.eps', meas_type, z_i)), 'ContentType','vector');
end
%% Method comparison

ref = load(fullfile(sprintf('%s_out', meas_type), ref_dir, 'refvals.mat'));
mean_ref = ref.vals.(recon_header.vialset).mean;
std_ref = ref.vals.(recon_header.vialset).std;

figure; plot(mean_ref, mean_sort,  '*', 'LineWidth',2); errorbarxy(mean_ref, mean_sort, std_ref, std_sort)
hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2); axis square;
ylabel(sprintf('Compared %s [ms]', meas_type)); xlabel(sprintf('Reference %s [ms]', meas_type))
title(sprintf('%s array %s comparison', recon_header.vialset, meas_type));

maxmax = max([mean_sort(1)+std_sort(1) mean_ref(1)+std_ref(1)]);
ylim([0 maxmax])
xlim([0 maxmax])

set(gca, 'XScale', 'log')
set(gca, 'YScale', 'log')
line([20, maxmax], [20, maxmax], 'LineStyle', '--', 'Color', 'red', 'LineWidth', 2)
xticks([25, 50, 100, 200, 400, 800, 1600])
yticks([25, 50, 100, 200, 400, 800, 1600])

exportgraphics(gcf,fullfile(out_dir, 'comparison.eps'), 'ContentType','vector');

vals.(recon_header.vialset).mean = mean_sort;
vals.(recon_header.vialset).std = std_sort;

save(fullfile(out_dir, 'refvals.mat'), "vals");
