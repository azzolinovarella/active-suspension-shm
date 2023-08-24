function [fig1, fig2] = plot_residue(t, y_luenberger, y_hat_obsu_luenberger, ...
    y1_hat_obs1_luenberger, y2_hat_obs2_luenberger, y_kalman, y_hat_obsu_kalman, ...
    y1_hat_obs1_kalman, y2_hat_obs2_kalman, sim_case, b_filter, a_filter, ... 
    save, save_path1, save_path2)

    % TODO2: Ajustar para obter residuo do UIO

    % Luenberger 
    r1_obsu_luenberger = filter(b_filter, a_filter, (y_luenberger.y1 - y_hat_obsu_luenberger.y1_hat));
    r2_obsu_luenberger = filter(b_filter, a_filter, (y_luenberger.y2 - y_hat_obsu_luenberger.y2_hat));
    r1_obs1_luenberger = filter(b_filter, a_filter, (y_luenberger.y1 - y1_hat_obs1_luenberger.y1_hat));
    r2_obs2_luenberger = filter(b_filter, a_filter, (y_luenberger.y2 - y2_hat_obs2_luenberger.y2_hat));

    % Kalman 
    r1_obsu_kalman = filter(b_filter, a_filter, (y_kalman.y1 - y_hat_obsu_kalman.y1_hat));
    r2_obsu_kalman = filter(b_filter, a_filter, (y_kalman.y2 - y_hat_obsu_kalman.y2_hat));
    r1_obs1_kalman = filter(b_filter, a_filter, (y_kalman.y1 - y1_hat_obs1_kalman.y1_hat));
    r2_obs2_kalman = filter(b_filter, a_filter, (y_kalman.y2 - y2_hat_obs2_kalman.y2_hat));

    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    plot(t, r1_obsu_luenberger); hold on
    plot(t, r1_obs1_luenberger)
    plot(t, r1_obsu_kalman)
    plot(t, r1_obs1_kalman)
    xline(t(end)/2, 'k--')
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    xlim([t(1), t(end)])
    grid on
    legend('Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    if ~save
        title(sprintf('Residuo 1 para caso %s', sim_case));
        legend('Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    end
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    plot(t, r2_obsu_luenberger); hold on
    plot(t, r2_obs2_luenberger)
    plot(t, r2_obsu_kalman)
    plot(t, r2_obs2_kalman)
    ylabel('r_2(t) (m/s^2)')
    xlabel('t (s)')
    xline(t(end)/2, 'k--')
    xlim([t(1), t(end)])
    grid on
    legend('Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    if ~save
        title(sprintf('Residuo 2 para caso %s', sim_case));
        legend('Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
    
end

