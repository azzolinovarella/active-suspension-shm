function [fig1, fig2] = plot_residue(t, y, y_hat, b_filter, a_filter)

    % Luenberger 
    r1_obsu = filter(b_filter, a_filter, (y.y1 - y_hat.y1_hat));
    r2_obsu = filter(b_filter, a_filter, (y.y2 - y_hat.y2_hat));

    fig1 = figure;
    
    hold on
    
    plot(t, r1_obsu, 'Color', '#053C5E', 'DisplayName', 'Luenberger observador unico')
    % xline(t(end)/2, 'k--', 'LineWidth', 2)
    xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    xlim([t(1), t(end)])
    legend('Location', 'northwest')
    grid on

    title(sprintf('Residuo 1 para caso %s', sim_case));

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    hold on
    % plot(t, r2_obsu, 'Color', '#053C5E', 'DisplayName', 'Luenberger observador unico')
    % plot(t, r2_obs2_luenberger, 'Color', '#1F7A8C', 'DisplayName', 'Luenberger banco de observadores')
    % plot(t, r2_obsu_kalman, 'Color', '#A31621', 'DisplayName', 'Kalman observador unico')
    % plot(t, r2_obs2_kalman, 'Color', '#F37748', 'DisplayName', 'Kalman banco de observadores')
    plot(t, r2_obsu, 'Color', '#053C5E')
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

