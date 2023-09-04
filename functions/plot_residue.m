function [fig1, fig2] = plot_residue(t, y_luenberger, y_hat_obsu_luenberger, ...
    y1_hat_obs1_luenberger, y2_hat_obs2_luenberger, y_kalman, y_hat_obsu_kalman, ...
    y1_hat_obs1_kalman, y2_hat_obs2_kalman, sim_case, b_filter, a_filter, ... 
    save, save_path1, save_path2)

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
    hold on
    % plot(t, r1_obsu_luenberger, 'Color', '#053C5E')
    % plot(t, r1_obs1_luenberger, 'Color', '#1F7A8C')
    % plot(t, r1_obsu_kalman, 'Color', '#A31621')
    % plot(t, r1_obs1_kalman, 'Color', '#F37748')
    plot(t, r1_obsu_luenberger, 'Color', '#053C5E', 'DisplayName', 'Luenberger observador unico')
    plot(t, r1_obs1_luenberger, 'Color', '#1F7A8C', 'DisplayName', 'Luenberger banco de observadores')
    plot(t, r1_obsu_kalman, 'Color', '#A31621', 'DisplayName', 'Kalman observador unico')
    plot(t, r1_obs1_kalman, 'Color', '#F37748', 'DisplayName', 'Kalman banco de observadores')
    % xline(t(end)/2, 'k--', 'LineWidth', 2)
    xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    xlim([t(1), t(end)])
    legend('Location', 'northwest')
    grid on

    if ~save
        title(sprintf('Residuo 1 para caso %s', sim_case));
        legend('on', 'Location', 'northeastoutside', 'Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    end
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    hold on
    % plot(t, r2_obsu_luenberger, 'Color', '#053C5E', 'DisplayName', 'Luenberger observador unico')
    % plot(t, r2_obs2_luenberger, 'Color', '#1F7A8C', 'DisplayName', 'Luenberger banco de observadores')
    % plot(t, r2_obsu_kalman, 'Color', '#A31621', 'DisplayName', 'Kalman observador unico')
    % plot(t, r2_obs2_kalman, 'Color', '#F37748', 'DisplayName', 'Kalman banco de observadores')
    plot(t, r2_obsu_luenberger, 'Color', '#053C5E')
    plot(t, r2_obs2_luenberger, 'Color', '#1F7A8C')
    plot(t, r2_obsu_kalman, 'Color', '#A31621')
    plot(t, r2_obs2_kalman, 'Color', '#F37748')  
    ylabel('r_2(t) (m/s^2)')
    xlabel('t (s)')
    % xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
    xline(t(end)/2, 'k--', 'LineWidth', 2)
    xlim([t(1), t(end)])
    grid on
    % legend('Location', 'northeastoutside')
    % legend('Location', 'northeast')
    if ~save
        title(sprintf('Residuo 2 para caso %s', sim_case));
    end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
    
end

