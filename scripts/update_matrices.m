function [A, B1, B2, C, D] = update_matrices(mv, ks, bs, mr, kp, bp)
    A = [0 1 0 -1; -ks/mv -bs/mv 0 bs/mv; 0 0 0 1; ks/mr bs/mr -kp/mr -(bs+bp)/mr];
    B1 = [0; 0; -1; bp/mr];
    B2 = [0; 1/mv; 0; -1/mr];
    % B = [B1 B2];
    C = [1 0 0 0; -ks/mv -bs/mv 0 bs/mv];
    D = [0; 1/mv];
end

