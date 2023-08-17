function fig = plot_noise_dist(v, n_bins, signal_ref, unit_ref, save, save_path, increase_yticks_distance)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end
    
    % Histograma
    yyaxis left
    histogram(v, n_bins);
    ylabel('Número de ocorrências');
    if increase_yticks_distance
        yticks_values = yticks;
        yticks_labels = strcat(cellstr(num2str(yticks_values')), char(160), char(160));
        yticklabels(yticks_labels);
    end

    % Densidade de probabilidade
    yyaxis right
    ksdensity(v)
    ylabel('Densidade de probabilidade');
    if increase_yticks_distance
        yticks_values = yticks;
        yticks_labels = strcat(cellstr(num2str(yticks_values')), char(160), char(160));
        yticklabels(yticks_labels);
    end

    if ~save, title(['Distribuição do ruído adicionado a y_', signal_ref, '(t)']); end
    xlabel(['Amplitude do ruído (', unit_ref, ')'])
    grid on  % Para manter o padrao...

    if save && exist('save_path', 'var'); exportgraphics(fig, save_path); end
end
