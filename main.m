clear; close all; clc

% Parametros para definir estilo de grafico
set(0,'DefaultLineLineWidth', 1.5, ...
    'DefaultAxesFontName', 'Latin Modern Math', ...
    'DefaultAxesFontSize', 14, ...
    'DefaultFigurePosition', [403 914 900 600]);  

% Para add o path das funçoes ao script atual
addpath(genpath('./functions'))

% Parametros da simulaçao
dt = 2.5E-5;  % Para que a gente consiga visualizar bem
f_sr = 1/dt;
T = 32;  % Deve ser par

%% Parametros da suspensao da quanser e matrizes do sistema

fprintf('Definindo parametros e matrizes do sistema...\n')

mv = 2.45;  % [mv] = kg --> Massa de 1/4 do veiculo
% mv = 1.45;  % [mv] = kg --> Massa de 1/4 do veiculo
ks = 900;   % [ks] = N/m --> Constante elastica da suspensao
bs = 7.5;   % [bs] = Ns/m --> Coeficiente de amortecimento da suspensao
mr = 1;     % [mr] = kg --> Massa do eixo-roda
kp = 1250;  % [kp] = N/m --> Constante elastica do pneu
bp = 5;     % [bp] = Ns/m --> Coeficiente de amortecimento do pneu

[A, B1, B2, C, D] = get_matrices(mv, ks, bs, mr, kp, bp);

%% Sinal de Chirp

fprintf('Gerando sinal de chirp...\n')

%%% Chirp 
% Parametros para gerar o sinal
As = 0.1;
% As = 0.2;
T0 = T/2;
f0 = 1/T0;
k1 = 0*(1/f0);  % Fica mais claro do que k1 = 0*T0
k2 = 10*(1/f0);
t = 0:dt:T0;
N = 2;  % Numero de periodos

% Sinal gerado
[w, t] = generate_chirp(As, T0, k1, k2, t, N);
W = cov(w);
% Exportando para arquivo
wt = timeseries(w, t);
save('./data/chirp_data.mat', 'wt', '-v7.3')

% Salvando as figuras
%%% No tempo
plot_chirp(t, w, [t(1), t(end), -As*1.1, As*1.1], true, './figs/chirp.png');
%%% Na frequencia
ii = ceil(length(t)/2);
w_ = w(1:ii);  % Fazendo assim pois dois concatenados da bug...
plot_fspec(w_, length(w_)*10, dt, [k1*f0, k2*f0+2, -20, 1], [k1*f0, k2*f0+2, -185, 185], true, true, './figs/chirp_mag.png');

%% Ruido de mediçao e processo

fprintf('Gerando sinal de ruido...\n')

% Pegando y e os valores maximos
sys = ss(A, B1, C, 0);  % B1 pois queremos estudar apenas w(t)
y = lsim(sys, w, t);
y1 = y(:,1);
y2 = y(:,2);

% Procedimento para gerar matriz de variancia
% SNR = 20;  % 20dB --> Sinal eh 100x mais potente que o ruido
SNR = 30;  % 30dB --> Sinal eh 1000x mais potente que o ruido
[v_y1, v_var_y1] = generate_noise(SNR, y1);
[v_y2, v_var_y2] = generate_noise(SNR, y2);

% Gerando a matriz de covariancia
V = cov(v_y1, v_y2); 
v = [v_y1; v_y2];
 
vt = timeseries(v, t);
save('./data/measurement_noise.mat', 'vt', '-v7.3')

% Salvando as figuras
%%% Ruido 1
plot_noise(t, v(1,:), [0, 32, 1.1*min(v(1,:)), 1.1*max(v(1,:))], '1', 'm', true, './figs/noise_v1.png');
plot_noise_dist(v(1,:), 30, '1', 'm', true, './figs/noise_v1_dist.png');
%%% Ruido 2
plot_noise(t, v(2,:), [0, 32, 1.1*min(v(2,:)), 1.1*max(v(2,:))], '2', 'm/s', true, './figs/noise_v2.png');
plot_noise_dist(v(2,:), 30, '2', 'm/s', true, './figs/noise_v2_dist.png');

%% Projeto dos observadores e do filtro

fprintf('Projetando ganhos dos observadores e filtros...\n')

p = eig(A);  % Polos da planta
C_obs1 = C(1, :);  % Matriz de saida do observador 1
D_obs1 = D(1, :);
C_obs2 = C(2, :);  % Matriz de saida do observador 2
D_obs2 = D(2, :);

%%% Luenberger
%%%% Polos desejados para o observador
p_luenberger = [-20, -15, -10, -5];
% p_luenberger = 4*p;
%%%% Observador 1
Ko1_luenberger = place(A', C_obs1', p_luenberger)';
%%%% Observador 2
Ko2_luenberger = place(A', C_obs2', p_luenberger)';
%%%% Observador unico
Kou_luenberger = place(A', C', p_luenberger)';

%%% Kalman
%%%% Observador 1
[Ko1_kalman, ~, ~] = lqe(A, B1, C_obs1, W, v_var_y1);  % Tem que ser v_var_y1 porque eh da saida 1 apenas
%%%% Observador 2
[Ko2_kalman, ~, ~] = lqe(A, B1, C_obs2, W, v_var_y2);  % Idem
%%%% Observador unico
[Kou_kalman, ~, ~] = lqe(A, B1, C, W, V);  % Agora eh V porque tem a matriz de covariancia...

%%% [PAUSADO POR ORA] UIO - TODO: Problema! Usando aceleraçao nao eh possivel...
%%%% Polos desejados para o observador 
% p_uio = 4*p;
%%%% Observador unico - nao temos o caso de banco de observadores aqui
% [N_obsu, L_obsu, G_obsu, E_obsu, Kou_uio] = project_uio(A, B1, B2, C, p_uio);  % APENAS w(t) como sinal desconhecido

%%% Filtro passa-baixas
[b_filter, a_filter] = butter(2, 75/(f_sr*pi), 'low');   % wc = 25 + wn2

%% Diagrama de bode e simulaçao para cada caso de dano

fprintf('Gerando diagrama de bode e rodando as simulaçoes...\n')

%%% Situaçoes de analise
%%% Caso 1: Perda do amortecimento da suspensao de 50%
bs_ = 0.5*bs;
[A_c1, B1_c1, B2_c1, C_c1, D_c1] = get_matrices(mv, ks, bs_, mr, kp, bp);
%%% Caso 2: Perda da rigidez da mola da suspensao de 50%
ks_ = 0.5*ks;
[A_c2, B1_c2, B2_c2, C_c2, D_c2] = get_matrices(mv, ks_, bs, mr, kp, bp);
%%% Caso 3: Perda de amortecimento da suspensao e da rigidez da mola de 50%
bs_ = 0.5*bs; ks_ = 0.5*ks;
[A_c3, B1_c3, B2_c3, C_c3, D_c3] = get_matrices(mv, ks_, bs_, mr, kp, bp);

% Condiçoes iniciais
% CI = [1; 1; 1; 1];
CI = [0; 0; 0; 0];

sys_hlt = ss(A, B1, C, D);  % Nao precisamos usar B2 (vamos analisar apenas a influencia de w)

for sim_case = ['1', '2', '3']  % Cada caso da simulacao
    A_sim_case = eval(sprintf('A_c%s', sim_case));
    B1_sim_case = eval(sprintf('B1_c%s', sim_case));
    B2_sim_case = eval(sprintf('B2_c%s', sim_case));
    C_sim_case = eval(sprintf('C_c%s', sim_case));
    D_sim_case = eval(sprintf('D_c%s', sim_case));
    sys_dmg = ss(A_sim_case, B1_sim_case, C_sim_case, D_sim_case);

    % Diagrama de bode para cada situacao de falha
    plot_sys_bode(sys_hlt, sys_dmg, sim_case, k1*f0+eps, k2*f0 + 5, [0, 60, -35, 0], [0, 60, 15, 50], true, sprintf('./figs/bode_y1_c%s.png', sim_case), sprintf('./figs/bode_y2_c%s.png', sim_case));

    % Projeto dos observadores
    [t_luenberger, ~, y_luenberger, ~, ~, ~, y_hat_obsu_luenberger, y1_hat_obs1_luenberger, y2_hat_obs2_luenberger] = run_sim('./simulations', 'luenberger');
    [t_kalman, ~, y_kalman, ~, ~, ~, y_hat_obsu_kalman, y1_hat_obs1_kalman, y2_hat_obs2_kalman] = run_sim('./simulations', 'kalman');
    % [t_uio, ~, y_uio, ~, ~, ~, y_hat_obsu_uio, y1_hat_obs1_uio, y2_hat_obs2_uio] = run_sim('./simulations', 'uio');

    % Plotagens -- TODO: CONVERTER PARA FUNÇOES DPS!
    %%% Residuos para os diferentes casos
    if sim_case == '1', plot_denoiser_ex(t_luenberger, y_luenberger, y1_hat_obs1_luenberger, b_filter, a_filter, [0 16 -3.5E-3 3.5E-3], true, './figs/filtering_ex1.png', './figs/filtering_ex2.png'); end  % So na primeira execuçao  
    
    plot_residue(t_luenberger, y_luenberger, y_hat_obsu_luenberger, y1_hat_obs1_luenberger, ...
                 y2_hat_obs2_luenberger, y_kalman, y_hat_obsu_kalman, y1_hat_obs1_kalman, ...
                 y2_hat_obs2_kalman, sim_case, b_filter, a_filter, true, sprintf('./figs/residue1_c%s.png', sim_case), ...
                 sprintf('./figs/residue2_c%s.png', sim_case));
end
