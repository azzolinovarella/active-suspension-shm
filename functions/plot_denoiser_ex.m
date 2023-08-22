function [fig1, fig2] = plot_denoiser_ex(t, y, y_hat, b_filter, a_filter, limits, save, save_path1, save_path2)
    y1 = y.y1;
    y1_hat = y_hat.y1_hat;
    r = y1 - y1_hat;
    r_filtered = filter(b_filter, a_filter, r);
    
    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    plot(t, r)
    grid on
    if ~save; title('Resíduo não filtrado'); end
    ylabel('Amplitude (m)')
    xlabel('t (s)')
    axis(limits)

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    plot(t, r_filtered)
    grid on
    if ~save; title('Resíduo filtrado'); end
    ylabel('Amplitude (m)')
    xlabel('t (s)')
    axis(limits)

    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
end

