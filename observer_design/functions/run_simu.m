function fig = run_simu(sim_dir, sim_name, b_filter, a_filter)
    %% Execuçao da simulacao
    % Para evitar criar slxc e slprj
    default_path = pwd;
    cd(sim_dir)
    sim_out = sim(sim_name);
    cd(default_path)
    
    % Parametros da simulaçao
    t = sim_out.tout;
    y_ = sim_out.y;
    y_hat_obs_ = sim_out.y_hat_obs;
    % Extraindo info
    %%% y
    y1 = squeeze(y_(1,1,:));
    y2 = squeeze(y_(2,1,:));
    %%% y_hat
    y1_hat_obs = squeeze(y_hat_obs_(1,1,:));
    y2_hat_obs = squeeze(y_hat_obs_(2,1,:));

    % Para facilitar, vamos criar uma struct
    y = struct('y1', y1, 'y2', y2);
    y_hat_obs = struct('y1_hat', y1_hat_obs, 'y2_hat', y2_hat_obs);

    r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
    r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));

    % Determinacao dos limiares
    L1 = max(abs(r1_obs(1:ceil(length(r1_obs)/2))));
    L2 = max(abs(r2_obs(1:ceil(length(r2_obs)/2))));
    
    %% Plotagem
    fig = figure;
    fig.Position = [200, 200, 1200, 500];  % Para ficar maior em subplot

    subplot(1, 2, 1) 
    % subplot(2, 1, 1)
    plot(t, r1_obs)
    hold on
    yline(L1, 'r--')
    yline(-L1, 'r--')
    grid on
    ylabel('r_1(t) (m)')
    xlabel('t (s)')
    xline(t(end)/2, 'k--', 'LineWidth', 2)
    xlim([t(1), t(end)])
    % annotation('textarrow', [0.3, 0.5175], [0.8, 0.775], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
    hold off
    
    subplot(1, 2, 2)
    % subplot(2, 1, 2) 
    plot(t, r2_obs)
    hold on
    yline(L2, 'r--')
    yline(-L2, 'r--')
    grid on
    ylabel('r_2(t) (m/s^2)')
    xlabel('t (s)')
    xline(t(end)/2, 'k--', 'LineWidth', 2)
    xlim([t(1), t(end)])
    % annotation('textarrow', [0.3, 0.5175], [0.8, 0.775], 'String', sprintf('Momento\ndo dano '), 'FontSize', 14, 'FontName', 'Latin Modern Math')
    hold off

    fprintf('Limiares: %.2d & %.2d', L1, L2)
end

