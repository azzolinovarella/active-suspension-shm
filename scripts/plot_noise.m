function fig = plot_noise(t, v, limits, signal_ref, unit_ref, save, save_path, increase_yticks_distance)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    plot(t, v);
    if ~save, title(['Ruído adicionado a y_', signal_ref, '(t)']); end
    ylabel(['v_', signal_ref, '(t) (', unit_ref, ')']);
    xlabel('t (s)')
    grid on
    axis(limits)
    if increase_yticks_distance
        yticks_values = yticks;
        yticks_labels = strcat(cellstr(num2str(yticks_values')), char(160), char(160));
        yticklabels(yticks_labels);
    end

    if save && exist('save_path', 'var'); exportgraphics(fig, save_path); end
end
