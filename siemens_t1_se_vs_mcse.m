addpath(genpath('thirdparty/'))
vialset = 'MnCl2';
mean_t2_mcse = [1813.5 1343.6 985.7 666.1 464.2 331.3 237.1 168.5 117.9 84.8 61.2 46  33.6 23.8];
std_t2_mcse  = [  57.8   31    24.2  14.5   7.3   6.4   4.9   4.5   4.3  2.4  2.4 1.5  1.2  0.9];

mean_t2_sese = [1720.37 1437.05 1086.18 725.75 499.53 350.31 249.33 180.83 124.75 85.99 59.5 42.14 29.6  20.41];
std_t2_sese  = [ 438.33  133.08   30.93  27.21  20.23  10.14  9.83    5.88   3.39  3.09  2.65 1.78  1.55  1.24];


figure; plot(mean_t2_sese, mean_t2_mcse,  '*', 'LineWidth',2); 
errorbarxy(mean_t2_sese, mean_t2_mcse, std_t2_sese, std_t2_mcse)
hold on; plot([0, max(mean_t2_sese)], [0, max(mean_t2_sese)], 'r--', LineWidth=2); axis square;
ylabel('MCSE T2 [ms]'); xlabel('SESE T2 [ms]')
title(sprintf('%s array T2 comparison', vialset));
xlim([0 2500]); ylim([0 2500])
set(findall(gcf,'-property','FontSize'),'FontSize',20)