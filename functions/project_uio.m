function [N, L, G, E, Ko_uio] = project_uio(A, B1, B2, C, p_obs)
    E = -B1*pinv(C*B1);
    H = eye(length(E)) + E*C;
    A1 = H*A;
    G = H*B2;
    Ko_uio = place(A1', C', p_obs)';
    N = A1 - Ko_uio*C;
    L = Ko_uio - N*E;
end