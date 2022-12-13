addpath(genpath('src/'))
if ~exist('filename', 'var')
    filename = 'meas_MID00116_FID47424_pulseq3D_vfa_sinc_16+8_spgr';
end

if ~exist('ref_dir', 'var')
    ref_dir = 'zhibo_ref';
end

out_dir = fullfile('T1map_out/', filename);

mkdir(fullfile('T1map_out', filename))

load(fullfile("input_data", filename))

vial_T1 = vial_masks.*T1*1e3;

nvial = 14;

mean_sort = zeros(nvial,1);
std_sort = zeros(nvial,1);
fid = fopen(fullfile(out_dir, 'stats.txt'), 'wt');
for v_i=1:nvial
    nzs = nonzeros(vial_T1(:,:,:,v_i));
    mean_sort(v_i) = mean(nzs, 'omitnan');
    std_sort(v_i) = std(nzs, 'omitnan');
    sline = sprintf('Vial %i = %.3f ± %.3f [ms]\n', v_i, mean_sort(v_i), std_sort(v_i));
    fprintf(sline)
    fprintf(fid, sline);
end

%% 
Nslc = size(T1, 3);
for z_i=1:Nslc
    f = figure; imagesc(T1(:,:,z_i).*1e3); axis image; colormap turbo; colorbar;
    title(sprintf("Slice: %i, %s T1 map [ms]", z_i, recon_header.vialset))
    % ax1 = gca;
    
    exportgraphics(gcf,fullfile(out_dir, sprintf('T1map_scl%i.eps', z_i)), 'ContentType','vector');
end
%% Method comparison

% if strcmp(recon_header.vialset, 'MnCl2')    % Zhibo MnCl2
%     meanZhibo = [2555 2363 1907.9 1521.1 1122.8 980.6 749.7 563.5 387.8 263.2 204.9 142.7 107.5 74.8];
%     stdZhibo = [670.4 460.8 208.4 141.1 74.8 54.7 31.2 23.1 12.7 8.9 9.8 7.2 6.8 6.8];
% elseif strcmp(recon_header.vialset, 'NiCl2') % NiCl2 Zhibo
%     meanZhibo = [2004.8 1527.8 1097 735.8 520.5 367.9 264.4 190.1 132.7 93.1 63.7 41.2 28.6 20.2];
%     stdZhibo = [184.6 78.9 43.7 18.4 12.2 7.4 5.7 4.4 3.6 2.7 2.9 7.8 7 8.8];
% end

ref = load(fullfile('T1map_out', ref_dir, 'refvals.mat'));
mean_ref = ref.vals.(recon_header.vialset).mean;
std_ref = ref.vals.(recon_header.vialset).std;

figure; plot(mean_ref, mean_sort,  '*', 'LineWidth',2); errorbarxy(mean_ref, mean_sort, std_ref, std_sort)
hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2); axis square;
ylabel('Pulseq VFA GRE T1 [ms]'); xlabel('IRSE T1 [ms]')
title(sprintf('%s array T1 comparison', recon_header.vialset));

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
