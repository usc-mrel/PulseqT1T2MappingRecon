if ~exist('filename', 'var')
    filename = 'meas_MID00188_FID08175_pulseqT2_lower';
end

if ~exist('ref_dir', 'var')
    ref_dir = 'zhibo_ref';
end

addpath(genpath('src/'))

% load(sprintf("T2map_out/%s_StimFit.mat", vialset))
load(fullfile("input_data", filename))

out_dir = fullfile('T2map_out/', filename);
mkdir(out_dir)

vial_T2 = vial_masks.*T2*1e3;

nvial = 14;

mean_sort = zeros(nvial,1);
std_sort = zeros(nvial,1);

fid = fopen(fullfile(out_dir, 'stats.txt'), 'wt');
for v_i=1:nvial
    nzs = nonzeros(vial_T2(:,:,v_i));
    mean_sort(v_i) = mean(nzs, 'omitnan');
    std_sort(v_i) = std(nzs, 'omitnan');
    line = sprintf('Vial %i = %.3f ± %.3f [ms]\n ', v_i, mean_sort(v_i), std_sort(v_i));
    fprintf(line)
    fprintf(fid, line);
end



f = figure; imagesc(T2*1e3); axis image; colormap turbo; colorbar;
title(sprintf("%s T2 map", recon_header.vialset))
exportgraphics(gcf,fullfile(out_dir, 'T2map.eps'), 'ContentType','vector');

%% If comparison
% if strcmp(recon_header.vialset, 'MnCl2')    % Zhibo MnCl2
%     meanZhibo = [1156.3 860.7 624.4 430 289.9 239.9 178 129.2 87.9 59 46 32.5 25.1 19.3];
%     stdZhibo = [55.2 37.5 20.9 12.2 10.6 8.5 6 4.7 4.3 3 2.9 2.8 2.1 2.2];
% elseif strcmp(recon_header.vialset, 'NiCl2') % NiCl2 Zhibo
%     meanZhibo = [1813.5 1343.6 985.7 666.1 464.2 331.3 237.1 168.5 117.9 84.8 61.2 46 33.6 23.8];
%     stdZhibo = [57.8 31 24.2 14.5 7.3 6.4 4.9 4.5 4.3 2.4 2.4 1.5 1.2 0.9];
% end

ref = load(fullfile('T2map_out', ref_dir, 'refvals.mat'));
mean_ref = ref.vals.(recon_header.vialset).mean;
std_ref = ref.vals.(recon_header.vialset).std;

figure; plot(mean_ref, mean_sort,  '*', 'LineWidth',2); errorbarxy(mean_ref, mean_sort, std_ref', std_sort)
hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2); axis square;
ylabel('Pulseq MCSE T_2 [ms]'); xlabel('Siemens Single Echo SE T_2 [ms]')
title(sprintf('%s array T2 comparison', recon_header.vialset));

maxmax = max([mean_sort(1)+std_sort(1) mean_ref(1)+std_ref(1)]);
ylim([0 maxmax])
xlim([0 maxmax])
exportgraphics(gcf,fullfile(out_dir, 'T2_pervial.eps'), 'ContentType','vector');

vals.(recon_header.vialset).mean = mean_sort;
vals.(recon_header.vialset).std = std_sort;

save(fullfile(out_dir, 'refvals.mat'), "vals");