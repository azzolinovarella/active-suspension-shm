function [w, t] = generate_chirp(A, T0, k1, k2, t, N)
    % Valores auxiliares
    f0 = 1/T0;
    a = pi*(k2 - k1)*f0^2;
    b = 2*pi*k1*f0^2;
    % Sinal
    w = A*sin((a*t + b).*t);

    for i=2:N
        t_ = t(2:end);
        tt = (i-1)*T0 + t_;
        ww = A*sin((a*t_ + b).*t_);
        w = [w, ww];
        t = [t, tt];
    end
end