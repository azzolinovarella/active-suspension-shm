function [fig1, fig2, fig3, fig4] = plot_sys_bode_var(mv, ks, bs, mr, kp, bp, ...
    variable_parameter, percentual_range, f1, f2, colors, limits1, limits2, ...
    limits3, limits4, save, save_path1, save_path2, save_path3, save_path4)   

    if save
        fig1 = figure('Visible', 'off');
    else
        fig1 = figure;
    end

    if save
        fig2 = figure('Visible', 'off');
    else
        fig2 = figure;
    end

    if save
        fig3 = figure('Visible', 'off');
    else
        fig3 = figure;
    end

    if save
        fig4 = figure('Visible', 'off');
    else
        fig4 = figure;
    end

    for i = 1:length(percentual_range)
        percentual_decrease = percentual_range(i);
        color = colors(i);

        switch variable_parameter
            case 'mv'
                mv_ = (1 - percentual_decrease)*mv;
                [A, B1, B2, C, D] = get_matrices(mv_, ks, bs, mr, kp, bp);
            case 'ks'
                ks_ = (1 - percentual_decrease)*ks;
                [A, B1, B2, C, D] = get_matrices(mv, ks_, bs, mr, kp, bp);
            case 'bs'
                bs_ = (1 - percentual_decrease)*bs;
                [A, B1, B2, C, D] = get_matrices(mv, ks, bs_, mr, kp, bp);
            case 'mr'
                mr_ = (1 - percentual_decrease)*mr;
                [A, B1, B2, C, D] = get_matrices(mv, ks, bs, mr_, kp, bp);
            case 'kp'
                kp_ = (1 - percentual_decrease)*kp;
                [A, B1, B2, C, D] = get_matrices(mv, ks, bs, mr, kp_, bp);
            case 'bp'
                bp_ = (1 - percentual_decrease)*bp;
                [A, B1, B2, C, D] = get_matrices(mv, ks, bs, mr, kp, bp_);       
        end
        
        sys_w = ss(A, B1, C, 0);
        sys_u = ss(A, B2, C, D);

        w = logspace(log10(f1*2*pi), log10(f2*2*pi), 10000);

        % Analisando quando w e entrada
        [y_w_bode, ~, wout_w] = bode(sys_w, w);
        y1_w_bode = mag2db(squeeze(y_w_bode(1,1,:)));
        y2_w_bode = mag2db(squeeze(y_w_bode(2,1,:)));
        set(0, 'CurrentFigure', fig1); hold on
        semilogx(wout_w, y1_w_bode, 'Color', color, 'DisplayName', sprintf('%0.f%%', 100*percentual_decrease))
        set(0, 'CurrentFigure', fig2); hold on
        semilogx(wout_w, y2_w_bode, 'Color', color, 'DisplayName', sprintf('%0.f%%', 100*percentual_decrease))
    
        % Analisando quando u e entrada
        [y_u_bode, ~, wout_u] = bode(sys_u, w);
        y1_u_bode = mag2db(squeeze(y_u_bode(1,1,:)));
        y2_u_bode = mag2db(squeeze(y_u_bode(2,1,:)));
        set(0, 'CurrentFigure', fig3); hold on
        semilogx(wout_u, y1_u_bode, 'Color', color, 'DisplayName', sprintf('%0.f%%', 100*percentual_decrease))
        set(0, 'CurrentFigure', fig4); hold on
        semilogx(wout_u, y2_u_bode, 'Color', color, 'DisplayName', sprintf('%0.f%%', 100*percentual_decrease))
    end
    
    set(0, 'CurrentFigure', fig1)
    xlabel('\Omega (rad/s)')
    ylabel('|Y_1(\Omega)/\omega(\Omega)| (dB)')
    grid on
    box on
    if ~save, title(sprintf('Variaçao de %s', variable_parameter)); end  
    axis(limits1)

    set(0, 'CurrentFigure', fig2) 
    xlabel('\Omega (rad/s)')
    ylabel('|Y_2(\Omega)/\omega(\Omega)| (dB)')
    grid on
    box on
    legend('Location', 'northeastoutside')
    if ~save, title(sprintf('Variaçao de %s', variable_parameter)); end 
    axis(limits2)

    set(0, 'CurrentFigure', fig3)
    xlabel('\Omega (rad/s)')
    ylabel('|Y_1(\Omega)/U(\Omega)| (dB)')
    grid on
    box on
    if ~save, title(sprintf('Variaçao de %s', variable_parameter)); end 
    axis(limits3)

    set(0, 'CurrentFigure', fig4)
    xlabel('\Omega (rad/s)')
    ylabel('|Y_2(\Omega)/U(\Omega)| (dB)')
    grid on
    box on
    legend('Location', 'northeastoutside')
    if ~save, title(sprintf('Variaçao de %s', variable_parameter)); end
    axis(limits4)

    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end
    if save && exist('save_path3', 'var'); save_fig(fig3, save_path3); end
    if save && exist('save_path4', 'var'); save_fig(fig4, save_path4); end  
end