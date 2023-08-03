function plot_fspec(w, N, dt, limits, normalize)
    W = fft(w, N);
    
    W_mag = abs(W);
    if normalize
        W_mag = (W_mag - min(W_mag))/(max(W_mag) - min(W_mag));
    end
    W_mag = mag2db(W_mag);

    W_phase = rad2deg(angle(W));
    
    f = (0:N-1)/(N*dt);
    
    figure
    
    ax1 = subplot(2, 1, 1);
    plot(f, W_mag);
    title('Espectro de amplitude e fase')
    ylabel('Amplitude (dB)')
    grid on
    axis(limits(1,:))
    
    ax2 = subplot(2, 1, 2);
    plot(f, W_phase);
    ylabel('Fase (°)')
    xlabel('f (Hz)')
    grid on

    linkaxes([ax1,ax2],'x')

    axis(limits(2,:))
end