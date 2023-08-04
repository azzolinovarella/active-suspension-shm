function [v, v_var] = generate_noise(SNR, y)
    s_y = std(y);
    s_r = s_y/(10^(SNR/20));
    v_var = s_r^2;
    v = s_r*randn(1, length(y));
end