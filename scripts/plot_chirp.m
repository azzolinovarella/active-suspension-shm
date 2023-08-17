function fig = plot_chirp(t, w, limits, save, save_path, increase_yticks_distance)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end

    plot(t, w)
    if ~save, title('Sinal de Chirp Utilizado'); end
    xlabel('t (s)')
    ylabel('\omega(t) (m/s)');
    grid on
    axis(limits)
    
    % Para nao ficar com o eixo bugado...
    if increase_yticks_distance
        yticks_values = yticks;
        yticks_labels = strcat(cellstr(num2str(yticks_values')), char(160), char(160));
        yticklabels(yticks_labels);
    end
    
    if save && exist('save_path', 'var'); exportgraphics(fig, save_path); end
end
