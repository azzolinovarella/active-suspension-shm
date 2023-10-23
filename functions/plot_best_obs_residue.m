function [fig1, fig2] = plot_best_obs_residue(t, y_real, y_hat, sim_case, ...
    r1_limit, r2_limit, limits1, limits2, b_filter, a_filter, plot_dmg_time, ...
    save, save_path1, save_path2)

    r1 = filter(b_filter, a_filter, (y_real.y1 - y_hat.y1_hat));
    r2 = filter(b_filter, a_filter, (y_real.y2 - y_hat.y2_hat));

    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    hold on
    % Plot do residuo como um todo
    plot(t, r1, 'Color', '#053C5E')
    yline(r1_limit, 'r--', 'LineWidth', 2)
    yline(-r1_limit, 'r--', 'LineWidth', 2)
    if plot_dmg_time
        xline(t(end)/2, 'k--', 'LineWidth', 2)
        % xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
        annotation('textarrow', [0.3, 0.5175], [0.8, 0.775], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
    end
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs([r1; r1_limit]))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    if class(limits1) == "string" && limits1 == "auto"
        axis([t(1) t(end) 1.1*min(r1) 1.1*max(r1)])
    else
        axis(limits1)
    end
    grid on
    box on
    if ~save
        title(sprintf('Residuo 1 para caso %s', sim_case));
    end
    % Plot da regiao ampliada
    % axes('position', [.20, .625, .25, .25])
    % plot(t(1:ceil(length(t)/2)), r1(1:ceil(length(t)/2)), 'Color', '#053C5E')
    % yline(r1_limit, 'r--', 'LineWidth', 2)
    % yline(-r1_limit, 'r--', 'LineWidth', 2)
    % grid on
    % box on   
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end


    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    % Plot do residuo como um todo
    hold on
    plot(t, r2, 'Color', '#053C5E')
    yline(r2_limit, 'r--', 'LineWidth', 2)
    yline(-r2_limit, 'r--', 'LineWidth', 2)
    if plot_dmg_time
        % xline(t(end)/2, 'k--', 'LineWidth', 2, 'DisplayName', 'Momento do dano')
        xline(t(end)/2, 'k--', 'LineWidth', 2, 'HandleVisibility','off')
        annotation('textarrow', [0.3, 0.5175], [0.8, 0.775], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
    end
    ylabel('r_2(t) (m/s^2)')
    xlabel('t (s)')
    % Para corrigir os eixos e ficar mais bonito (multiplos de 5E?)
    y_max = round(max(abs([r2; r2_limit]))/5, 1, 'significant')*5;
    yticks(linspace(-2*y_max, 2*y_max, 11))
    xticks(t(1):5:t(end))
    if class(limits2) == "string" && limits2 == "auto"
        axis([t(1) t(end) 1.1*min(r2) 1.1*max(r2)])
    else
        axis(limits2)
    end
    grid on
    box on
    if ~save
        title(sprintf('Residuo 2 para caso %s', sim_case));
    end
    % Plot da regiao ampliada
    % axes('position', [.20, .625, .25, .25])
    % plot(t(1:ceil(length(t)/2)), r2(1:ceil(length(t)/2)), 'Color', '#053C5E')
    % yline(r2_limit, 'r--', 'LineWidth', 2)
    % yline(-r2_limit, 'r--', 'LineWidth', 2)
    % grid on
    % box on
    
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
    
end

