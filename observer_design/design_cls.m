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

%%% Situaçoes de analise  
%%% Caso 0: Sem dano
[A_c0, B1_c0, B2_c0, C_c0, D_c0] = define_system(mv, ks, bs, mr, kp, bp);
%%% Caso 1: Perda do amortecimento da suspensao de 50%
bs_ = 0.5*bs;
[A_c1, B1_c1, B2_c1, C_c1, D_c1] = define_system(mv, ks, bs_, mr, kp, bp);

% Pegando matrizes de dano
sim_case = '0';
A_sim_case = eval(sprintf('A_c%s', sim_case));
B1_sim_case = eval(sprintf('B1_c%s', sim_case));
B2_sim_case = eval(sprintf('B2_c%s', sim_case));
C_sim_case = eval(sprintf('C_c%s', sim_case));
D_sim_case = eval(sprintf('D_c%s', sim_case));

p = eig(A);

%% Observador LUENBERGER unico com entrada w

fprintf('OBSERVADOR LUENBERGER UNICO COM ENTRADA w(t)\n');
%%% Apos busca fina
n_mul = 7;
m_mul = 0;
p_real = n_mul*real(p);
p_imag = m_mul*imag(p);

p_obsu_w = p_real + p_imag*1j;
if m_mul == 0
    p_obsu_w(2) = 1.25*p_obsu_w(1);
    p_obsu_w(4) = 1.25*p_obsu_w(3);
end

Ko = place(A', C', p_obsu_w)';
[~, ~, y, ~, y_hat_obs] = run_simu('.', 'luenberger_obsu_w_design');

r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));
fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

%% Observador LUENBERGER 1 com entrada w

fprintf('OBSERVADOR LUENBERGER 1 COM ENTRADA w(t)\n');
%%% Apos busca fina
n_mul = 2;
m_mul = 2;
p_real = n_mul*real(p);
p_imag = m_mul*imag(p);

p_obs1_w = p_real + p_imag*1j;
if m_mul == 0
    p_obs1_w(2) = 1.25*p_obs1_w(1);
    p_obs1_w(4) = 1.25*p_obs1_w(3);
end

Ko = place(A', C_obs1', p_obs1_w)';
[~, ~, y, ~, y_hat_obs] = run_simi('.', 'luenberger_obs1_w_design');

r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')

%% Observador LUENBERGER 2 com entrada w

fprintf('OBSERVADOR LUENBERGER 2 COM ENTRADA w(t)\n');
%%% Apos busca fina
n_mul = 2;
m_mul = 2;
p_real = n_mul*real(p);
p_imag = m_mul*imag(p);

p_obs2_w = p_real + p_imag*1j;
if m_mul == 0
    p_obs2_w(2) = 1.25*p_obs2_w(1);
    p_obs2_w(4) = 1.25*p_obs2_w(3);
end

Ko = place(A', C_obs2', p_obs2_w)';
[~, ~, y, ~, y_hat_obs] = run_simi('.', 'luenberger_obs2_w_design');

r2_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

%% Observador LUENBERGER unico com entrada u

fprintf('OBSERVADOR LUENBERGER UNICO COM ENTRADA u(t)\n');
%%% Apos busca fina
n_mul = 7;
m_mul = 0;

p_real = n_mul*real(p);

p_imag = m_mul*imag(p);

p_obsu_u = p_real + p_imag*1j;
if m_mul == 0
    p_obsu_u(2) = 1.25*p_obsu_u(1);
    p_obsu_u(4) = 1.25*p_obsu_u(3);
end

Ko = place(A', C', p_obsu_u)';
[~, ~, y, ~, y_hat_obs] = run_simu('.', 'luenberger_obsu_u_design');

r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obs.y1_hat));
r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obs.y2_hat));

fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

%% Observador LUENBERGER 1 com entrada u

fprintf('OBSERVADOR LUENBERGER 1 COM ENTRADA u(t)\n');
%%% Apos busca fina
n_mul = 5.5;
m_mul = 2.5;

p_real = n_mul*real(p);
p_imag = m_mul*imag(p);

p_obs1_u = p_real + p_imag*1j;
if m_mul == 0
    p_obs1_u(2) = 1.25*p_obs1_u(1);
    p_obs1_u(4) = 1.25*p_obs1_u(3);
end

Ko = place(A', C_obs1', p_obs1_u)';
[~, ~, y, ~, y_hat_obs] = run_simi('.', 'luenberger_obs1_u_design');

r1_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')

%% Observador LUENBERGER 2 com entrada u

fprintf('OBSERVADOR LUENBERGER 2 COM ENTRADA u(t)\n');
%%% Apos busca fina
n_mul = 5.5;
m_mul = 2.5;

p_real = n_mul*real(p);
p_imag = m_mul*imag(p);

p_obs2_u = p_real + p_imag*1j;
if m_mul == 0
    p_obs2_u(2) = 1.25*p_obs2_u(1);
    p_obs2_u(4) = 1.25*p_obs2_u(3);
end

Ko = place(A', C_obs2', p_obs2_u)';
[~, ~, y, ~, y_hat_obs] = run_simi('.', 'luenberger_obs2_u_design');

r2_obs = filter(b_filter, a_filter, (y.yi - y_hat_obs.yi_hat));

fprintf('Melhor matriz de ganho:');
disp(Ko)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

%% Observador KALMAN - TODOS

load('../data/chirp_u_data.mat')
load('../data/chirp_w_data.mat')
load('../data/measurement_noise_u_data.mat')
load('../data/measurement_noise_w_data.mat')

w = squeeze(wt.Data);
W = cov(w);
v_y1_w = squeeze(vt_w.Data(1,1,:));
v_y2_w = squeeze(vt_w.Data(2,1,:));

u = squeeze(ut.Data);
U = cov(u);
v_y1_u = squeeze(vt_u.Data(1,1,:));
v_y2_u = squeeze(vt_u.Data(2,1,:));

v_var_y1_w = cov(v_y1_w);
v_var_y2_w = cov(v_y2_w);
V_w = cov(v_y1_w, v_y2_w);

v_var_y1_u = cov(v_y1_u);
v_var_y2_u = cov(v_y2_u);
V_u = cov(v_y1_u, v_y2_u); 

%%% Kalman - MUDA CONFORME O RUIDO DE SAIDA MUDA!
%%%% Entrada w
%%%%% Banco de Observadores
[Ko1_kalman_w, ~, ~] = lqe(A, B1, C_obs1, W, v_var_y1_w);  % Tem que ser v_var_y1 porque eh da saida 1 apenas
[Ko2_kalman_w, ~, ~] = lqe(A, B1, C_obs2, W, v_var_y2_w);  % Idem
%%%%% Observador unico
[Kou_kalman_w, ~, ~] = lqe(A, B1, C, W, V_w);  % Agora eh V porque tem a matriz de covariancia...
%%%% Entrada u
% %%%%% Banco de Observadores
% [Ko1_kalman_u, ~, ~] = lqe(A, B1, C_obs1, U, v_var_y1_u);  % Tem que ser v_var_y1 porque eh da saida 1 apenas
% [Ko2_kalman_u, ~, ~] = lqe(A, B1, C_obs2, U, v_var_y2_u);  % Idem
[Ko1_kalman_u, ~, ~] = lqe(A, B2, C_obs1, 0, v_var_y1_u);  % Tem que ser v_var_y1 porque eh da saida 1 apenas
[Ko2_kalman_u, ~, ~] = lqe(A, B2, C_obs2, 0, v_var_y2_u);  % Idem
% %%%%% Observador unico
% [Kou_kalman_u, ~, ~] = lqe(A, B1, C, U, V_u);  % Agora eh V porque tem a matriz de covariancia...
[Kou_kalman_u, ~, ~] = lqe(A, B2, C, 0, V_u);  % Agora eh V porque tem a matriz de covariancia...

[~, ~, y, ~, ~, ~, y_hat_obsu, y1_hat_obs1, y2_hat_obs2] = run_sim('.', 'kalman_w_');

fprintf('OBSERVADOR KALMAN UNICO COM ENTRADA w(t)\n');
r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obsu.y1_hat));
r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obsu.y2_hat));
fprintf('Melhor matriz de ganho:');
disp(Kou_kalman_w)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

fprintf('OBSERVADOR KALMAN 1 COM ENTRADA w(t)\n');
r1_obs = filter(b_filter, a_filter, (y.y1 - y1_hat_obs1.y1_hat));
fprintf('Melhor matriz de ganho:');
disp(Ko1_kalman_w)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')

fprintf('OBSERVADOR KALMAN 2 COM ENTRADA w(t)\n');
r2_obs = filter(b_filter, a_filter, (y.y2 - y2_hat_obs2.y2_hat));
fprintf('Melhor matriz de ganho:');
disp(Ko2_kalman_w)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

% ------------------------------------------------------------------

[~, ~, y, ~, ~, ~, y_hat_obsu, y1_hat_obs1, y2_hat_obs2] = run_sim('.', 'kalman_u_');

fprintf('OBSERVADOR KALMAN UNICO COM ENTRADA u(t)\n');
r1_obs = filter(b_filter, a_filter, (y.y1 - y_hat_obsu.y1_hat));
r2_obs = filter(b_filter, a_filter, (y.y2 - y_hat_obsu.y2_hat));
fprintf('Melhor matriz de ganho:');
disp(Kou_kalman_u)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')

fprintf('OBSERVADOR KALMAN 1 COM ENTRADA u(t)\n');
r1_obs = filter(b_filter, a_filter, (y.y1 - y1_hat_obs1.y1_hat));
fprintf('Melhor matriz de ganho:');
disp(Ko1_kalman_u)
fprintf('Limiar r1:')
disp(1.5*max(abs(r1_obs(1:ceil(length(r1_obs)/2)))));
fprintf('\n\n')

fprintf('OBSERVADOR KALMAN 2 COM ENTRADA u(t)\n');
r2_obs = filter(b_filter, a_filter, (y.y2 - y2_hat_obs2.y2_hat));
fprintf('Melhor matriz de ganho:');
disp(Ko2_kalman_u)
fprintf('Limiar r2:')
disp(1.5*max(abs(r2_obs(1:ceil(length(r2_obs)/2)))));
fprintf('\n\n')