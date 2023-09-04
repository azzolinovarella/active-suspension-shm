function fig = plot_fspec(w, N, dt, limits, normalize, save, save_path)
% function fig = plot_fspec(w, N, dt, limits1, limits2, normalize, save, save_path)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    W = fft(w, N);
    
    W_mag = abs(W);
    if normalize
        W_mag = (W_mag - min(W_mag))/(max(W_mag) - min(W_mag));
    end
    W_mag = mag2db(W_mag);

    % W_phase = rad2deg(angle(W));
    
    f = (0:N-1)/(N*dt);
    
    % ax1 = subplot(2, 1, 1);
    plot(f, W_mag);
    if ~save, title('Espectro de Magnitude e Fase'); end
    ylabel('Magnitude (dB)');
    xlabel('f (Hz)')
    grid on
    axis(limits)
    
    % ax2 = subplot(2, 1, 2);
    % plot(f, W_phase);
    % ylabel('Fase (°)');
    % xlabel('f (Hz)')
    % grid on
    % linkaxes([ax1,ax2],'x')
    % axis(limits2)

    if save && exist('save_path', 'var'); save_fig(fig, save_path); end
end