function fig = plot_bad_obs_residue(t, y, y_hat_obs, b_filter, a_filter, ...
    plot_dmg_time, save, save_path)

    r1 = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));

    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end
    hold on

    plot(t, r1)    
    if plot_dmg_time
        % xline(t(end)/2, 'k--', 'LineWidth', 2)
        xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
        % annotation('textarrow', [0.3, 0.5175], [0.775, 0.75], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
        annotation('textarrow', [0.32, 0.5175], [0.85, 0.775], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
    end
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    % xlim([t(1), t(end)])
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs(r1))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    axis([t(1) t(end) 1.1*min(r1) 1.1*max(r1)])
    % legend('Location', 'northwest')
    % legend('Location', 'northwest', 'FontSize', 14)
    grid on
    box on

    if ~save
        title(sprintf('Residuo 1 para caso %s', sim_case));
        legend('on', 'Location', 'northeastoutside', 'Luenberger observador unico', 'Luenberger banco de observadores', ...
               'Kalman observador unico', 'Kalman banco de observadores')
    end
    if save && exist('save_path', 'var'); save_fig(fig, save_path); end    
end

