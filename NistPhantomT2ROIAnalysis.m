vialset = 'MnCl2'; % 'NiCl2', 'MnCl2'

load(sprintf("T2map_out/%s_StimFit.mat", vialset))

nvial = 14;
f = figure; imagesc(T2*1e3); axis image; colormap turbo; colorbar;
title("T2 map [ms]")
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
    h{v} = drawellipse(ax1, 'Center', h{v}.Center+[3 0],'SemiAxes',h{v}.SemiAxes);
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
    tissue_roi = T2(mask_roi(:,:,v));
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

%% If comparison
if strcmp(vialset, 'MnCl2')    % Zhibo MnCl2
    meanZhibo = [1156.3 860.7 624.4 430 289.9 239.9 178 129.2 87.9 59 46 32.5 25.1 19.3];
    stdZhibo = [55.2 37.5 20.9 12.2 10.6 8.5 6 4.7 4.3 3 2.9 2.8 2.1 2.2];
elseif strcmp(vialset, 'NiCl2') % NiCl2 Zhibo
    meanZhibo = [1813.5 1343.6 985.7 666.1 464.2 331.3 237.1 168.5 117.9 84.8 61.2 46 33.6 23.8];
    stdZhibo = [57.8 31 24.2 14.5 7.3 6.4 4.9 4.5 4.3 2.4 2.4 1.5 1.2 0.9];
end


figure; plot(meanZhibo, mean_sort,  '*', 'LineWidth',2); errorbarxy(meanZhibo, mean_sort, stdZhibo, std_sort)
hold on; plot([0, max(mean_sort)], [0, max(mean_sort)], 'r--', LineWidth=2); axis square;
ylabel('Pulseq MCSE T2 [ms]'); xlabel('Siemens MCSE T2 [ms]')
title(sprintf('%s array T2 comparison', vialset));

maxmax = max([mean_sort(1)+std_sort(1) meanZhibo(1)+stdZhibo(1)]);
ylim([0 maxmax])
xlim([0 maxmax])