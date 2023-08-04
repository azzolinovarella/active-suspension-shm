function fig = plot_chirp(t, w, limits)
    fig = figure;

    plot(t, w)
    % title('Sinal de Chirp Utilizado')
    xlabel('t (s)')
    ylabel('\omega(t) (m/s)')
    grid on
    axis(limits)
end
