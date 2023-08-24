function [fig1, fig2] = plot_residue(t, y_luenberger, y_hat_luenberger, y_kalman, y_hat_kalman, sim_case, b_filter, a_filter, save, save_path1, save_path2)
% function fig = plot_residue(t, y_luenberger, y_hat_luenberger, y_uio, y_hat_uio, y_kalman, y_hat_kalman, sim_case, b_filter, a_filter, save, save_path)
    % TODO1: Ajustar para obter residuo de observador unico tb...
    % TODO2: Ajustar para obter residuo do UIO

    % Luenberger 
    r1_luenberger = filter(b_filter, a_filter, (y_luenberger.y1 - y_hat_luenberger.y1_hat));
    r2_luenberger = filter(b_filter, a_filter, (y_luenberger.y2 - y_hat_luenberger.y2_hat));

    % Kalman 
    r1_kalman = filter(b_filter, a_filter, (y_kalman.y1 - y_hat_kalman.y1_hat));
    r2_kalman = filter(b_filter, a_filter, (y_kalman.y2 - y_hat_kalman.y2_hat));

    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    plot(t, r1_luenberger); hold on
    plot(t, r1_kalman)
    xline(t(end)/2, 'r--')
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    xlim([t(1), t(end)])
    
    grid on
    if ~save
        title(sprintf('Residuo 1 para caso %s', sim_case));
        legend('Luenberger', 'Kalman')
    end
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    plot(t, r2_luenberger); hold on
    plot(t, r2_kalman)
    ylabel('r_2(t) (m/s^2)')
    xlabel('t (s)')
    xline(t(end)/2, 'r--')
    xlim([t(1), t(end)])
    grid on
    if ~save
        title(sprintf('Residuo 2 para caso %s', sim_case));
        legend('Luenberger', 'Kalman')
    end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
    
end

