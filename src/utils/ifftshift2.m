function out = ifftshift2(in)
%FFTSHIFT3 Summary of this function goes here
%   Detailed explanation goes here
    out = ifftshift(ifftshift(in,1),2);
end

