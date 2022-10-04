function out = fft3(in)
%FFT3 Summary of this function goes here
%   Detailed explanation goes here
    out = fft(fft(fft(in, [], 1), [], 2), [], 3);
end

