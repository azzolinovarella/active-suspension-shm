function save_fig(fig, save_path)
    % Forma 1     
    exportgraphics(fig, save_path, 'Resolution', 600)
    
    % Forma 2
    % F = getframe(fig);
    % imwrite(F.cdata, save_path)
end

