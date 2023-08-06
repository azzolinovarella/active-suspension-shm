function [v, v_var] = generate_noise(SNR, y)
    y_rms = rms(y);
    v_var = (y_rms^2)/(10^(SNR/10));
    v = sqrt(v_var)*randn(1, length(y));
end