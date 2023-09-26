function [fig1, fig2] = plot_filter_bode(w_filter, H_filter, f_sr, limits1, limits2, save, save_path1, save_path2)   
    f_arr = w_filter * (f_sr / (2 * pi));
    w_arr = f_arr * 2*pi;

    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    hold on
    %%% Usando w
    semilogx(w_arr, 20*log10(abs(H_filter)))
    xlabel('\Omega (rad/s)')
    %%% Usando f
    % semilogx(f_arr, 20*log10(abs(H)))
    % xlabel('f (Hz)')
    grid on
    box on
    ylabel('Ganho do Filtro (dB)')
    axis(limits1)
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    hold on
    %%% Usando w
    semilogx(w_arr, rad2deg(angle(H_filter)))
    xlabel('\Omega (rad/s)')
    %%% Usando f
    % semilogx(f_arr, angle(H))
    % xlabel('f (Hz)')
    grid on
    box on
    ylabel('Fase do Filtro (°)')
    axis(limits2)
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
end