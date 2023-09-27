function [fig1, fig2] = plot_sys_bode(sys_hlt, sys_dmg, sim_case, f1, f2, ylimits1, ylimits2, save, save_path1, save_path2)   
    w = logspace(log10(f1*2*pi), log10(f2*2*pi), 10000);

    [y_hlt_bode, ~, wout_hlt] = bode(sys_hlt, w);
    y1_hlt_bode = mag2db(squeeze(y_hlt_bode(1,1,:)));
    y2_hlt_bode = mag2db(squeeze(y_hlt_bode(2,1,:)));

    [y_dmg_bode, ~, wout_dmg] = bode(sys_dmg, w);
    y1_dmg_bode = mag2db(squeeze(y_dmg_bode(1,1,:)));
    y2_dmg_bode = mag2db(squeeze(y_dmg_bode(2,1,:)));

    if save && exist('save_path1', 'var')
        fig1 = figure('visible', 'off');
    else
        fig1 = figure;
    end
    hold on
    %%% Usando w
    semilogx(wout_hlt, y1_hlt_bode)
    semilogx(wout_dmg, y1_dmg_bode)
    xlabel('\Omega (rad/s)')
    %%% Usando f
    % semilogx(wout_hlt/(2*pi), y1_hlt_bode)
    % semilogx(wout_dmg/(2*pi), y1_dmg_bode)
    % xlabel('f (Hz)')
    grid on
    box on
    ylabel('|Y_1(j\Omega)| (dB)')
    axis(ylimits1)
    if ~save, title(['Comparaçao do ganho 1 para sistema com dano do tipo ', sim_case]); legend('Saudavel', sprintf('Situacao de dano %s', sim_case)); end
    if save && exist('save_path1', 'var'); save_fig(fig1, save_path1); end

    if save && exist('save_path2', 'var')
        fig2 = figure('visible', 'off');
    else
        fig2 = figure;
    end
    hold on
    %%% Usando w
    semilogx(wout_hlt, y2_hlt_bode)
    semilogx(wout_dmg, y2_dmg_bode)
    xlabel('\Omega (rad/s)')
    %%% Usando f
    % semilogx(wout_hlt/(2*pi), y2_hlt_bode)
    % semilogx(wout_dmg/(2*pi), y2_dmg_bode)
    % xlabel('f (Hz)')
    grid on
    box on
    ylabel('|Y_2(j\Omega)| (dB)')
    axis(ylimits2)
    if ~save, title(['Comparaçao do ganho 2 para sistema com dano do tipo ', sim_case]); legend('Saudavel', sprintf('Situacao de dano %s', sim_case)); end    
    if save && exist('save_path2', 'var'); save_fig(fig2, save_path2); end  
end