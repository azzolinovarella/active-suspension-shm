function [t, x, y, x_hat_obsu, x_hat_obs1, x_hat_obs2, y_hat_obsu, y1_hat_obs1, y2_hat_obs2] = run_sim(sim_dir, sim_name)
    % Para evitar criar slxc e slprj
    default_path = pwd;
    cd(sim_dir)
    sim_out = sim(sim_name);
    cd(default_path)
    
    % Parametros da simulaçao
    t = sim_out.tout;
    x_ = sim_out.x;
    y_ = sim_out.y;
    x_hat_obsu_ = sim_out.x_hat_obsu;
    x_hat_obs1_ = sim_out.x_hat_obs1;
    x_hat_obs2_ = sim_out.x_hat_obs2;
    y_hat_obsu_ = sim_out.y_hat_obsu;
    y1_hat_obs1_ = sim_out.y_hat_obs1;
    y2_hat_obs2_ = sim_out.y_hat_obs2;
    % Extraindo info
    %%% x
    x1 = squeeze(x_(1,1,:));
    x2 = squeeze(x_(2,1,:));
    x3 = squeeze(x_(3,1,:));
    x4 = squeeze(x_(4,1,:));
    %%% y
    y1 = squeeze(y_(1,1,:));
    y2 = squeeze(y_(2,1,:));
    %%% x_hat_obsu
    x1_hat_obsu = squeeze(x_hat_obsu_(1,1,:));
    x2_hat_obsu = squeeze(x_hat_obsu_(2,1,:));
    x3_hat_obsu = squeeze(x_hat_obsu_(3,1,:));
    x4_hat_obsu = squeeze(x_hat_obsu_(4,1,:));
    %%% x_hat_obs1
    x1_hat_obs1 = squeeze(x_hat_obs1_(1,1,:));
    x2_hat_obs1 = squeeze(x_hat_obs1_(2,1,:));
    x3_hat_obs1 = squeeze(x_hat_obs1_(3,1,:));
    x4_hat_obs1 = squeeze(x_hat_obs1_(4,1,:));
    %%% x_hat_obs2
    x1_hat_obs2 = squeeze(x_hat_obs2_(1,1,:));
    x2_hat_obs2 = squeeze(x_hat_obs2_(2,1,:));
    x3_hat_obs2 = squeeze(x_hat_obs2_(3,1,:));
    x4_hat_obs2 = squeeze(x_hat_obs2_(4,1,:));
    %%% y_hat
    y1_hat_obsu = squeeze(y_hat_obsu_(1,1,:));
    y2_hat_obsu = squeeze(y_hat_obsu_(2,1,:));
    y1_hat_obs1__ = squeeze(y1_hat_obs1_);
    y2_hat_obs2__ = squeeze(y2_hat_obs2_);

    % Para facilitar, vamos criar uma struct
    x = struct('x1', x1, 'x2', x2, 'x3', x3, 'x4', x4);
    y = struct('y1', y1, 'y2', y2);
    x_hat_obsu = struct('x1_hat_obsu', x1_hat_obsu, 'x2_hat_obsu', x2_hat_obsu, 'x3_hat_obsu', x3_hat_obsu, 'x4_hat_obsu', x4_hat_obsu);
    x_hat_obs1 = struct('x1_hat_obs1', x1_hat_obs1, 'x2_hat_obs1', x2_hat_obs1, 'x3_hat_obs1', x3_hat_obs1, 'x4_hat_obs1', x4_hat_obs1);
    x_hat_obs2 = struct('x1_hat_obs2', x1_hat_obs2, 'x2_hat_obs2', x2_hat_obs2, 'x3_hat_obs2', x3_hat_obs2, 'x4_hat_obs2', x4_hat_obs2);
    y_hat_obsu = struct('y1_hat', y1_hat_obsu, 'y2_hat', y2_hat_obsu);
    y1_hat_obs1 = struct('y1_hat', y1_hat_obs1__);
    y2_hat_obs2 = struct('y2_hat', y2_hat_obs2__);
end

