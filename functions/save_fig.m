function save_fig(fig, save_path)
    % res = 600;  % Fica pesado no PDF
    % res = 450;  % Um pouco pesado
    res = 300;
    % res = 150;  % Grafico fica um pouco pixelado

    % Forma 1     
    exportgraphics(fig, save_path, 'Resolution', res)
    
    % Forma 2
    % F = getframe(fig);
    % imwrite(F.cdata, save_path)
end

