function fig = plot_noise(t, v, limits, signal_ref, unit_ref, noise_ref, save, save_path)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    plot(t, v);
    if ~save, title(['Ruído adicionado a y_', signal_ref, '(t)']); end
    ylabel(sprintf('%s_%s(t) (%s)', noise_ref, signal_ref, unit_ref));
    xlabel('t (s)')
    grid on
    box on
    axis(limits)

    if save && exist('save_path', 'var'); save_fig(fig, save_path); end
end
