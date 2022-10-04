function out = fftmod2(in)
    out = fftshift2(fft(fft(fftshift2(in), [], 1),[], 2));
end
