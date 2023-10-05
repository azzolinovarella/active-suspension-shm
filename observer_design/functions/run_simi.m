function fig = run_simi(sim_dir, sim_name, r_mul, i_mul, b_filter, a_filter)
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
    yi = squeeze(y_(1,1,:));
    %%% y_hat
    yi_hat_obs = squeeze(y_hat_obs_(1,1,:));

    % Para facilitar, vamos criar uma struct
    y = struct('yi', yi);
    y_hat_obs = struct('yi_hat', yi_hat_obs);
    
    ri_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

    % Determinacao dos limiares
    Li = max(abs(ri_obs(1:ceil(length(ri_obs)/2))));

    %% Plotagem
    fig = figure;
    fig.Position = [200, 200, 600, 500];  % Para equivalente ao subplot

    hold on  % Se quiser ver tudo junto
    plot(t, ri_obs)
    hold on
    yline(Li, 'r--')
    yline(-Li, 'r--')
    grid on
    ylabel('r_i(t) (S.U.)')
    xlabel('t (s)')
    xline(t(end)/2, 'k--', 'LineWidth', 2)
    xlim([t(1), t(end)])
    hold off
    
    fprintf('Velocidades: %.2f & %.2f \nLimiar: %.2d', r_mul, i_mul, Li)
end

