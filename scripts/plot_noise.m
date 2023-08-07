function fig = plot_noise(t, v, limits, signal_ref, unit_ref, save, save_path)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    plot(t, v);
    if ~save, title(['Ruído adicionado a y_', signal_ref, '(t)']); end
    ylabel(['v_', signal_ref, '(t) (', unit_ref, ')'])
    xlabel('t (s)')
    grid on
    axis(limits)

    if save && exist('save_path', 'var'); print(fig, '-dpng', save_path, '-r600'); end
end
