function fig = plot_chirp(t, w, signal_ref, signal_unit, limits, save, save_path)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    plot(t, w)
    if ~save, title('Sinal de Chirp Utilizado'); end
    xlabel('t (s)')
    ylabel(sprintf('%s (%s)', signal_ref, signal_unit));
    grid on
    box on
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs(w))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    axis(limits)
       
    if save && exist('save_path', 'var'); save_fig(fig, save_path); end
end
