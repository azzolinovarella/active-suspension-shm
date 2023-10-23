function [fig1, fig2] = plot_denoiser_ex(t, y, b_filter, a_filter, limits, save, save_path1, save_path2)
    y_filtered = filter(b_filter, a_filter, y);
    
    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    plot(t, y)
    grid on
    box on
    if ~save; title('Resíduo não filtrado'); end
    ylabel('Amplitude (m)')
    xlabel('t (s)')
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs(y))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    axis(limits)

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    plot(t, y_filtered)
    grid on
    box on
    if ~save; title('Resíduo filtrado'); end
    ylabel('Amplitude (m)')
    xlabel('t (s)')
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs(y))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    axis(limits)

    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
end

