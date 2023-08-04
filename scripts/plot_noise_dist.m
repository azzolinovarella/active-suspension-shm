function fig = plot_noise_dist(v, n_bins, signal_ref, unit_ref)
    fig = figure;
    
    % Histograma
    yyaxis left
    histogram(v, n_bins);
    ylabel('Número de ocorrências')

    % Densidade de probabilidade
    yyaxis right
    ksdensity(v)
    ylabel('Densidade de probabilidade')

    % title(['Distribuição do ruído adicionado a y_', signal_ref, '(t)'])
    xlabel(['Amplitude do ruído (', unit_ref, ')'])
    grid on  % Para manter o padrao...
end
