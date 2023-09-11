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
    is_better = 1;
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
            [t, ~, y, ~, y_hat_obs] = run_simi('.', sprintf('luenberger_obs%s_%s_design', obs_id, signal_id));
                    
            switch obs_id
                case '1'
                    r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));
                    
                    plot(t, r1_obs)
                    ylabel('r_1(t) (m)')
                    xlabel('t (s)')
                    xline(T/2, 'k--', 'LineWidth', 2)
                    hold off
            
                    sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
                                    
                case '2'
                    C_ = C_obs2;
                
                case 'u'
                    C_ = C;
            end
            
            
    
            % hold on  % Se quiser ver tudo junto
            plot(t, r2_obs)
            hold on  % Se quiser ver separado
            grid on
            ylabel('r_2(t) (m/s^2)')
            xlabel('t (s)')
            xline(T/2, 'k--', 'LineWidth', 2)
            hold off
    
            sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
            pause
        end
    end
end

