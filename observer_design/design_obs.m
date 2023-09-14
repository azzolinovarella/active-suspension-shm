clear; close all; clc

reset(0)

%% Parametros da simulaçao

dt = 2.5E-3;  % Para que a gente consiga visualizar bem e seja rapido
f_sr = 1/dt;
T = 32;  % Deve ser par
CI = [0; 0; 0; 0];
[b_filter, a_filter] = butter(2, 75/(f_sr*pi), 'low');   % wc = 25 + wn2 (padrao)

%% Geraçao do sinal de chirp e ruido

% TODO: Colocar aqui tambem a parte de gerar o sinal de chirp e ruido
% e colocar na simulacao o caminho certo tb... Outra opçao eh criar um 
% outro scrip para fazer isso em ambas. Importante fazer isso pois
% garantimos que o sinal estara amostrado corretamente para a filtragem

%% Parametros da suspensao da quanser e matrizes do sistema

mv = 2.45;  % [mv] = kg --> Massa de 1/4 do veiculo
% mv = 1.45;  % [mv] = kg --> Massa de 1/4 do veiculo
ks = 900;   % [ks] = N/m --> Constante elastica da suspensao
bs = 7.5;   % [bs] = Ns/m --> Coeficiente de amortecimento da suspensao
mr = 1;     % [mr] = kg --> Massa do eixo-roda
kp = 1250;  % [kp] = N/m --> Constante elastica do pneu
bp = 5;     % [bp] = Ns/m --> Coeficiente de amortecimento do pneu

[A, B1, B2, C, D] = define_system(mv, ks, bs, mr, kp, bp);
C_obs1 = C(1,:);
D_obs1 = D(1);
C_obs2 = C(2,:);
D_obs2 = D(2);

p = eig(A);

%% Situaçoes de dano

%%% Situaçoes de analise  
%%% Caso 1: Sem dano
[A_c0, B1_c0, B2_c0, C_c0, D_c0] = define_system(mv, ks, bs, mr, kp, bp);
%%% Caso 1: Perda do amortecimento da suspensao de 50%
bs_ = 0.5*bs;
[A_c1, B1_c1, B2_c1, C_c1, D_c1] = define_system(mv, ks, bs_, mr, kp, bp);
%%% Caso 2: Perda da rigidez da mola da suspensao de 50%
ks_ = 0.5*ks;
[A_c2, B1_c2, B2_c2, C_c2, D_c2] = define_system(mv, ks_, bs, mr, kp, bp);
%%% Caso 3: Perda de amortecimento da suspensao e da rigidez da mola de 50%
bs_ = 0.5*bs; ks_ = 0.5*ks;
[A_c3, B1_c3, B2_c3, C_c3, D_c3] = define_system(mv, ks_, bs_, mr, kp, bp);

% Pegando matrizes de dano
sim_case = '1';
A_sim_case = eval(sprintf('A_c%s', sim_case));
B1_sim_case = eval(sprintf('B1_c%s', sim_case));
B2_sim_case = eval(sprintf('B2_c%s', sim_case));
C_sim_case = eval(sprintf('C_c%s', sim_case));
D_sim_case = eval(sprintf('D_c%s', sim_case));

%% Projeto dos obs

% % Observador unico com entrada w
figure(1);
fprintf('OBSERVADOR UNICO COM ENTRADA w(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 7;
imag_space = 0;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obsu_w = p_real + p_imag*1j;
        if m_mul == 0
            p_obsu_w(2) = 1.25*p_obsu_w(1);
            p_obsu_w(4) = 1.25*p_obsu_w(3);
        end

        Ko = place(A', C', p_obsu_w)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simu('.', 'luenberger_obsu_w_design');

        r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
        r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));

        subplot(1, 2, 1) 
        hold on  % Se quiser ver tudo junto
        plot(t, r1_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_1(t) (m)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        subplot(1, 2, 2) 
        hold on  %3 Se quiser ver tudo junto
        plot(t, r2_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_2(t) (m/s^2)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r1_obs_best = r1_obs;
            r2_obs_best = r2_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs_best(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs_best(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')
close 1

% Observador 1 com entrada w
figure(2);
fprintf('OBSERVADOR 1 COM ENTRADA w(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 2;
imag_space = 2;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obs1_w = p_real + p_imag*1j;
        if m_mul == 0
            p_obs1_w(2) = 1.25*p_obs1_w(1);
            p_obs1_w(4) = 1.25*p_obs1_w(3);
        end

        Ko = place(A', C_obs1', p_obs1_w)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simi('.', 'luenberger_obs1_w_design');

        r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

        hold on  % Se quiser ver tudo junto
        plot(t, r1_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_1(t) (m)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r1_obs_best = r1_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs_best(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')
close 2

% Observador 2 com entrada w
figure(3);
fprintf('OBSERVADOR 2 COM ENTRADA w(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 2;
imag_space = 2;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obs2_w = p_real + p_imag*1j;
        if m_mul == 0
            p_obs2_w(2) = 1.25*p_obs2_w(1);
            p_obs2_w(4) = 1.25*p_obs2_w(3);
        end

        Ko = place(A', C_obs2', p_obs2_w)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simi('.', 'luenberger_obs2_w_design');

        r2_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

        hold on  % Se quiser ver tudo junto
        plot(t, r2_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_2(t) (m/s^2)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r2_obs_best = r2_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs_best(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')
close 3

% Observador unico com entrada u
figure(4);
fprintf('OBSERVADOR UNICO COM ENTRADA u(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 7;
imag_space = 0;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obsu_u = p_real + p_imag*1j;
        if m_mul == 0
            p_obsu_u(2) = 1.25*p_obsu_u(1);
            p_obsu_u(4) = 1.25*p_obsu_u(3);
        end

        Ko = place(A', C', p_obsu_u)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simu('.', 'luenberger_obsu_u_design');

        r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
        r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));

        subplot(1, 2, 1) 
        hold on  % Se quiser ver tudo junto
        plot(t, r1_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_1(t) (m)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        subplot(1, 2, 2) 
        hold on  % Se quiser ver tudo junto
        plot(t, r2_obs)
        % hold on  % Se quiser ver separado
        grid on
        ylabel('r_2(t) (m/s^2)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r1_obs_best = r1_obs;
            r2_obs_best = r2_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs_best(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs_best(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')
close 4

% Observador 1 com entrada u
figure(5);
fprintf('OBSERVADOR 1 COM ENTRADA u(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 5.5;
imag_space = 2.5;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obs1_u = p_real + p_imag*1j;
        if m_mul == 0
            p_obs1_u(2) = 1.25*p_obs1_u(1);
            p_obs1_u(4) = 1.25*p_obs1_u(3);
        end

        Ko = place(A', C_obs1', p_obs1_u)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simi('.', 'luenberger_obs1_u_design');

        r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

        % hold on  % Se quiser ver tudo junto
        plot(t, r1_obs)
        hold on  % Se quiser ver separado
        grid on
        ylabel('r_1(t) (m)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r1_obs_best = r1_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs_best(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')
close 5

% Observador 2 com entrada u
figure(6);
fprintf('OBSERVADOR 2 COM ENTRADA u(t)\n');
%%% Para fazer uma busca fina
% real_space = linspace(4, 10, 5);
% imag_space = linspace(0, 10, 5);
%%% Apos busca fina
real_space = 5.5;
imag_space = 2.5;
for n_mul = real_space
    p_real = n_mul*real(p);
    for m_mul = imag_space
        p_imag = m_mul*imag(p);

        p_obs2_u = p_real + p_imag*1j;
        if m_mul == 0
            p_obs2_u(2) = 1.25*p_obs2_u(1);
            p_obs2_u(4) = 1.25*p_obs2_u(3);
        end

        Ko = place(A', C_obs2', p_obs2_u)';
        [t, x, y, x_hat_obs, y_hat_obs] = run_simi('.', 'luenberger_obs2_u_design');

        r2_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

        % hold on  % Se quiser ver tudo junto
        plot(t, r2_obs)
        hold on  % Se quiser ver separado
        grid on
        ylabel('r_2(t) (m/s^2)')
        xlabel('t (s)')
        xline(T/2, 'k--', 'LineWidth', 2)
        hold off

        sgtitle(sprintf('%.2f & %.2f', n_mul, m_mul))
        
        best_res = input('Melhor resultado? ');
        if best_res
            Ko_best = Ko;
            r2_obs_best = r2_obs;
        end
    end
end
fprintf('Melhor matriz de ganho:');
disp(Ko_best)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs_best(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')
close 6