function u = chirp(A,f0, k1, k2, t)
    % Valores auxiliares
    % Do livro
    a = pi*(k2 - k1)*f0^2;
    b = 2*pi*k1*f0^2;
    % Corrigido por mim
    %%% a = 2*pi*(k2 - k1)*f0^2;
    %%% b = 2*pi*k1*f0;
    % Sinal
    u = A*sin((a*t + b).*t);
end