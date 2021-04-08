% Calc and draw FFT.
% Inputs:   signal - signal to analyze.
%           dt - sample interval in sec (not whole capture time).
% Outputs: ps - array of doubles, power spectrum.
%           f - array of doubles, frequency.
function [ps, f] = drawFFT(signal, dt, draw_plot)
    num_samples = length(signal);
    signal_ft = fft(signal);
    amp = abs(signal_ft); 
    ps = amp.^2;
    f = (0 : num_samples-1) / (num_samples * dt);
    
    if draw_plot
        figure('Name','Power Spectra');
        plot(f , ps);
        title('Power Spectra');
        xlabel('frequency(Hz)');
        ylabel('Power Spectrum');
    end
end