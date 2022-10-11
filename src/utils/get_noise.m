function [noise] = get_noise(raw_data_noise)
%GET_NOISE Summary of this function goes here
%   Detailed explanation goes here
is_noise = raw_data_noise.head.flagIsSet('ACQ_IS_NOISE_MEASUREMENT');
meas = raw_data_noise.select(find(is_noise));
nr_repetitions = length(meas.data); % number of repetitions

[nr_samples,nr_channels] = size(meas.data{1});
noise = complex(zeros(nr_samples, nr_repetitions, 1, nr_channels, 'single'));
for idx = 1:nr_repetitions
    noise(:,idx,1,:) = meas.data{idx}; % nr_samples x nr_channels => nr_channels x nr_samples
end
end

