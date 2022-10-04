
vialset = 'NiCl2'; % 'NiCl2', 'MnCl2'


load(sprintf("T1map_out/%s_T1Fit.mat", vialset));


%% 

nvial = 14;
f = figure; imagesc(T1.*1e3); axis image; colormap turbo; colorbar;
title(sprintf("%s T1 map [ms]", vialset))
ax1 = gca;
% % First Ellipse is for the Tissue ROI
% for v=1:nvial
% %     title(sprintf('Draw Vial %d ROI',v))
%     h{v} = drawellipse(ax1, 'Center',[50,50],'SemiAxes',[3,3]);
% %     wait(h{v})
% end
% c = uicontrol('String','Continue','Callback','uiresume(f)');
% uiwait(f)

load('nist_vial_ellipses.mat')

for v=1:nvial
    h{v} = drawellipse(ax1, 'Center', h{v}.Center + [4 0],'SemiAxes',h{v}.SemiAxes, 'Color', 'red');
end

c = uicontrol('String','Continue','Callback','uiresume(f)');
uiwait(f)

% Extract masks
for v=1:nvial
    mask_roi(:,:,v) = createMask(h{v});
end
%% Calculate SNR based on ROIs
idx = 1;
mean_roi = zeros(nvial,1);
std_roi = zeros(nvial,1);

for v=1:nvial
    tissue_roi = T1(mask_roi(:,:,v));
    mean_roi(v, :) = mean(abs(tissue_roi), 1)*1e3;
    std_roi(v, :) = std(abs(tissue_roi), 1)*1e3;
end

[mean_sort,I] = sort(mean_roi, 'descend');
std_sort = std_roi(I);

fprintf('\nVial\tMean \x00B1 Std [ms]\n')
disp('-----------------------------------')
for v=1:nvial
    fprintf('%i\t%.1f \x00B1 %.1f\n',v, mean_sort(v), std_sort(v))
end

%% Method comparison

if strcmp(vialset, 'MnCl2')    % Zhibo MnCl2
    meanZhibo = [2555 2363 1907.9 1521.1 1122.8 980.6 749.7 563.5 387.8 263.2 204.9 142.7 107.5 74.8];
    stdZhibo = [670.4 460.8 208.4 141.1 74.8 54.7 31.2 23.1 12.7 8.9 9.8 7.2 6.8 6.8];
elseif strcmp(vialset, 'NiCl2') % NiCl2 Zhibo
    meanZhibo = [2004.8 1527.8 1097 735.8 520.5 367.9 264.4 190.1 132.7 93.1 63.7 41.2 28.6 20.2];
    stdZhibo = [184.6 78.9 43.7 18.4 12.2 7.4 5.7 4.4 3.6 2.7 2.9 7.8 7 8.8];
end

% figure; plot(mean_sort, meanZhibo, 'LineWidth',2); errorbarxy(mean_sort, meanZhibo, std_sort, stdZhibo)
% hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2);
% ylabel('Zhibo T1 [ms]'); xlabel('Bilal T1 [ms]')
% title('NiCl2 array T1 comparison')



figure; plot(meanZhibo, mean_sort,  '*', 'LineWidth',2); errorbarxy(meanZhibo, mean_sort, stdZhibo, std_sort)
hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2); axis square;
ylabel('Pulseq VFA GRE T1 [ms]'); xlabel('IRSE T1 [ms]')
title(sprintf('%s array T1 comparison', vialset));

maxmax = max([mean_sort(1)+std_sort(1) meanZhibo(1)+stdZhibo(1)]);
ylim([0 maxmax])
xlim([0 maxmax])