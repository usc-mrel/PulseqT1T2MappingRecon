function out = fftmod3(in)
    out = fftshift3(fft3(fftshift3(in)));
end
