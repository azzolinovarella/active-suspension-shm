function fig = plot_noise(t, v, limits, signal_ref, unit_ref)
    fig = figure;

    plot(t, v);
    % title(['Ruído adicionado a y_', signal_ref, '(t)'])
    ylabel(['v_', signal_ref, '(t) (', unit_ref, ')'])
    xlabel('t (s)')
    grid on
    axis(limits)
end
