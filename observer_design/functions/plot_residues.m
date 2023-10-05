function fig = plot_residues(A, C, real_linspace, imag_linspace, a_filter, b_filter, obs_id, signal_id)
    p = eig(A);
    
    switch obs_id
        case '1'
            C_ = C(1,:);
        case '2'
            C_ = C(2,:);
        case 'u'
            C_ = C;
    end

    
    fig = figure;
    
    sim_itter = 0;
    for n_mul = real_linspace
        p_real = n_mul*real(p);
        for m_mul = imag_linspace
            p_imag = m_mul*imag(p);
    
            p_obs = p_real + p_imag*1j;
            if m_mul == 0
                p_obs(2) = 1.25*p_obs(1);
                p_obs(4) = 1.25*p_obs(3);
            end
            
            Ko = place(A', C_', p_obs)';
                    
            switch obs_id
                case '1'
                    [t, ~, y, ~, y_hat_obs] = run_simi('.', sprintf('luenberger_obs%s_%s_design', obs_id, signal_id), Ko);
                    r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));
                    
                    plot(t, r1_obs)
                    ylabel('r_1(t) (m)')
                    xlabel('t (s)')
                    sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
                    if sim_itter == 0 
                        r1_obs_better = r1_obs;
                        p_obs_better = p_obs;
                    end
                    hold on
                    plot(t, r1_obs_better)
                    legend('Resultado atual', 'Melhor resultado')
                    xline(T/2, 'k--', 'LineWidth', 2)
                    hold off

                    is_better = input('Melhor resultado ate agora? ');
                    if is_better 
                        r1_obs_better = r1_obs;
                        p_obs_better = p_obs;
                    end
                                    
                case '2'
                    [t, ~, y, ~, y_hat_obs] = run_simi('.', sprintf('luenberger_obs%s_%s_design', obs_id, signal_id), Ko);
                    r2_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));
                    
                    plot(t, r2_obs)
                    ylabel('r_2(t) (m/s^2)')
                    xlabel('t (s)')
                    sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
                    if sim_itter == 0 
                        r2_obs_better = r2_obs;
                        p_obs_better = p_obs;
                    end
                    hold on
                    plot(t, r2_obs_better)
                    legend('Resultado atual', 'Melhor resultado')
                    xline(T/2, 'k--', 'LineWidth', 2)
                    hold off

                    is_better = input('Melhor resultado ate agora? ');
                    if is_better 
                        r2_obs_better = r2_obs;
                        p_obs_better = p_obs;
                    end
                
                case 'u'
                    [t, ~, y, ~, y_hat_obs] = run_simu('.', sprintf('luenberger_obs%s_%s_design', obs_id, signal_id));
                    r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
                    r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));
                    
                    subplot(1, 2, 1)
                    plot(t, r1_obs)
                    ylabel('r_1(t) (m)')
                    xlabel('t (s)')
                    subplot(1, 2, 2)
                    plot(t, r2_obs)
                    ylabel('r_2(t) (m/s^2)')
                    xlabel('t (s)')
                    sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
                    if sim_itter == 0 
                        r1_obs_better = r1_obs;
                        r2_obs_better = r2_obs;
                        p_obs_better = p_obs;
                    end
                    hold on
                    subplot(1, 2, 1)
                    plot(t, r1_obs_better)
                    subplot(1, 2, 2)
                    plot(t, r2_obs_better)
                    legend('Resultado atual', 'Melhor resultado')
                    xline(T/2, 'k--', 'LineWidth', 2)
                    hold off

                    is_better = input('Melhor resultado ate agora? ');
                    if is_better 
                        r2_obs_better = r2_obs;
                        p_obs_better = p_obs;
                    end
            end

            sim_itter = sim_iter + 1;
        end
    end

    fprintf('Melhor polo: %f', p_obs_better)
end

