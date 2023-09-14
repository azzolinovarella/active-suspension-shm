function [t, x, y, x_hat_obs, y_hat_obs] = run_simi(sim_dir, sim_name)
    % Para evitar criar slxc e slprj
    default_path = pwd;
    cd(sim_dir)
    sim_out = sim(sim_name);
    cd(default_path)
    
    % Parametros da simulaçao
    t = sim_out.tout;
    x_ = sim_out.x;
    y_ = sim_out.y;
    x_hat_obs_ = sim_out.x_hat_obs;
    y_hat_obs_ = sim_out.y_hat_obs;
    % Extraindo info
    %%% x
    x1 = squeeze(x_(1,1,:));
    x2 = squeeze(x_(2,1,:));
    x3 = squeeze(x_(3,1,:));
    x4 = squeeze(x_(4,1,:));
    %%% y
    yi = squeeze(y_(1,1,:));
    %%% x_hat_obs
    x1_hat_obs = squeeze(x_hat_obs_(1,1,:));
    x2_hat_obs = squeeze(x_hat_obs_(2,1,:));
    x3_hat_obs = squeeze(x_hat_obs_(3,1,:));
    x4_hat_obs = squeeze(x_hat_obs_(4,1,:));
    %%% y_hat
    yi_hat_obs = squeeze(y_hat_obs_(1,1,:));

    % Para facilitar, vamos criar uma struct
    x = struct('x1', x1, 'x2', x2, 'x3', x3, 'x4', x4);
    y = struct('yi', yi);
    x_hat_obs = struct('x1_hat_obs', x1_hat_obs, 'x2_hat_obs', x2_hat_obs, 'x3_hat_obs', x3_hat_obs, 'x4_hat_obs', x4_hat_obs);
    y_hat_obs = struct('yi_hat', yi_hat_obs);
end

