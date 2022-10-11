function out = fftshift2(in)
%FFTSHIFT3 Summary of this function goes here
%   Detailed explanation goes here
    out = fftshift(fftshift(in,1),2);
end

