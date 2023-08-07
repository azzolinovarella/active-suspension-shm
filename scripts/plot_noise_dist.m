function fig = plot_noise_dist(v, n_bins, signal_ref, unit_ref, save, save_path)
    if save && exist('save_path', 'var')
        fig = figure('visible', 'off');
    else
        fig = figure;
    end
    
    % Histograma
    yyaxis left
    histogram(v, n_bins);
    ylabel('Número de ocorrências')

    % Densidade de probabilidade
    yyaxis right
    ksdensity(v)
    ylabel('Densidade de probabilidade')

    if ~save, title(['Distribuição do ruído adicionado a y_', signal_ref, '(t)']); end
    xlabel(['Amplitude do ruído (', unit_ref, ')'])
    grid on  % Para manter o padrao...

    if save && exist('save_path', 'var'); print(fig, '-dpng', save_path, '-r600'); end
end
