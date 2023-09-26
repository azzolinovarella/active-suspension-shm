function print_residue_rmse(t, y_luenberger, y_hat_obsu_luenberger, ...
    y1_hat_obs1_luenberger, y2_hat_obs2_luenberger, y_kalman, y_hat_obsu_kalman, ...
    y1_hat_obs1_kalman, y2_hat_obs2_kalman, sim_case, signal_id, ...
    b_filter, a_filter)
    
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

    fprintf('=-=-=-=-=-=-=-  Caso %s | Entrada %s -=-=-=-=-=-=\n', sim_case, signal_id)
    fprintf('================== Residuo 1 ==================\n')
    fprintf('----------------- Luenberger ------------------\n')
    fprintf('- OBSU: %.2d\t%.2d\n', rmse(r1_obsu_luenberger(1:ceil(length(t)/2)), 0), rmse(r1_obsu_luenberger(ceil(length(t)/2):end), 0))
    fprintf('- OBS1: %.2d\t%.2d\n', rmse(r1_obs1_luenberger(1:ceil(length(t)/2)), 0), rmse(r1_obs1_luenberger(ceil(length(t)/2):end), 0))
    fprintf('-----------------------------------------------\n')
    fprintf('------------------- Kalman --------------------\n')
    fprintf('- OBSU: %.2d\t%.2d\n', rmse(r1_obsu_kalman(1:ceil(length(t)/2)), 0), rmse(r1_obsu_kalman(ceil(length(t)/2):end), 0))
    fprintf('- OBS1: %.2d\t%.2d\n', rmse(r1_obs1_kalman(1:ceil(length(t)/2)), 0), rmse(r1_obs1_kalman(ceil(length(t)/2):end), 0))
    fprintf('-----------------------------------------------\n')
    fprintf('===============================================\n')

    fprintf('================== Residuo 2 ==================\n')
    fprintf('----------------- Luenberger ------------------\n')
    fprintf('- OBSU: %.2d\t%.2d\n', rmse(r2_obsu_luenberger(1:ceil(length(t)/2)), 0), rmse(r2_obsu_luenberger(ceil(length(t)/2):end), 0))
    fprintf('- OBS2: %.2d\t%.2d\n', rmse(r2_obs2_luenberger(1:ceil(length(t)/2)), 0), rmse(r2_obs2_luenberger(ceil(length(t)/2):end), 0))
    fprintf('-----------------------------------------------\n')
    fprintf('------------------- Kalman --------------------\n')
    fprintf('- OBSU: %.2d\t%.2d\n', rmse(r2_obsu_kalman(1:ceil(length(t)/2)), 0), rmse(r2_obsu_kalman(ceil(length(t)/2):end), 0))
    fprintf('- OBS2: %.2d\t%.2d\n', rmse(r2_obs2_kalman(1:ceil(length(t)/2)), 0), rmse(r2_obs2_kalman(ceil(length(t)/2):end), 0))
    fprintf('-----------------------------------------------\n')
    fprintf('===============================================\n')
    fprintf('=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n\n')
end

