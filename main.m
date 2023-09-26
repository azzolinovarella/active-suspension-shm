clear; close all; clc

%%% Bom para um grafico so
set(0,'DefaultLineLineWidth', 1.5, ...
    'DefaultAxesFontName', 'Latin Modern Math', ...
    'DefaultAxesFontSize', 20, ...
    'DefaultFigurePosition', [403 914 900 600]); 

% Para add o path das funçoes ao script atual
addpath(genpath('./functions'))

% Parametros da simulaçao
% dt = 2.5E-5;  % Para que a gente consiga visualizar bem
dt = 2.5E-3;  % Para ir rapido --> diminuir para melhorar resolucao
% dt = 2.5E-4;  % Meio termo
f_sr = 1/dt;
% T = 32;  % Deve ser par
T = 40;  % Deve ser par

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

% Parametros gerais do sinal de chirp
T0 = T/2;
f0 = 1/T0;
k1 = 0*(1/f0);  % Fica mais claro do que k1 = 0*T0
k2 = 10*(1/f0);
t = 0:dt:T0;
N = 2;  % Numero de periodos

%%% Chirp para w(t)
% Parametros para gerar o sinal
Aw = 0.1;
% Sinal gerado
[w, tw] = generate_chirp(Aw, T0, k1, k2, t, N);
W = cov(w);
% Exportando para arquivo
wt = timeseries(w, tw);
save('./data/chirp_w_data.mat', 'wt', '-v7.3')
% Salvando as figuras
%%% No tempo
plot_chirp(tw, w, '\omega(t)', 'm/s', [tw(1), tw(end), -Aw*1.1, Aw*1.1], true, './figs/chirp/chirp_w.png');
%%% Na frequencia
ii = ceil(length(tw)/2);
w_ = w(1:ii);  % Fazendo assim pois dois concatenados da bug...
plot_fspec(w_, length(w_)*10, dt, [k1*f0, k2*f0+2, -20, 1], true, true, './figs/chirp/chirp_w_mag.png');
% plot_fspec(w_, length(w_)*10, dt, [k1*f0, k2*f0+2, 10, 30], false, true, './figs/chirp/chirp_w_mag.png');  % Limites conhecidos de antemao

%%% Chirp para u(t)
% Parametros para gerar o sinal
Au = 5;
% Sinal gerado
[u, tu] = generate_chirp(Au, T0, k1, k2, t, N);
U = cov(u);
% Exportando para arquivo
ut = timeseries(u, tu);
save('./data/chirp_u_data.mat', 'ut', '-v7.3')
% Salvando as figuras
%%% No tempo
plot_chirp(tu, u, 'u(t)', 'N', [tu(1), tu(end), -Au*1.1, Au*1.1], true, './figs/chirp/chirp_u.png');
%%% Na frequencia
ii = ceil(length(tu)/2);
u_ = u(1:ii);  % Fazendo assim pois dois concatenados da bug...
plot_fspec(u_, length(u_)*10, dt, [k1*f0, k2*f0+2, -20, 1], true, true, './figs/chirp/chirp_u_mag.png');
% plot_fspec(u_, length(u_)*10, dt, [k1*f0, k2*f0+2, 30, 50], false, true, './figs/chirp/chirp_u_mag.png');  % Limites conhecidos de antemao

%% Ruido de mediçao e processo

fprintf('Gerando sinal de ruido...\n')

% SNR = 20;  % 20dB --> Sinal eh 100x mais potente que o ruido
SNR = 30;  % 30dB --> Sinal eh 1000x mais potente que o ruido

% Pegando y e os valores maximos para w(t)
sys_w = ss(A, B1, C, 0);  % B1 pois queremos estudar apenas w(t)
y_w = lsim(sys_w, w, tw);
y1_w = y_w(:,1);
y2_w = y_w(:,2);
% Procedimento para gerar matriz de variancia
[v_y1_w, v_var_y1_w] = generate_noise(SNR, y1_w);
[v_y2_w, v_var_y2_w] = generate_noise(SNR, y2_w);
% Gerando a matriz de covariancia
V_w = cov(v_y1_w, v_y2_w); 
v_w = [v_y1_w; v_y2_w];
vt_w = timeseries(v_w, tw);
save('./data/measurement_noise_w_data.mat', 'vt_w', '-v7.3')
% Salvando as figuras
%%% Ruido 1
plot_noise(tw, v_w(1,:), [0, 32, 1.1*min(v_w(1,:)), 1.1*max(v_w(1,:))], '1', 'm', ...
           true, './figs/noise/noise_v1_w.png');
plot_noise_dist(v_w(1,:), 30, '1', 'm', true, './figs/noise/noise_v1_w_dist.png');
%%% Ruido 2
plot_noise(tw, v_w(2,:), [0, 32, 1.1*min(v_w(2,:)), 1.1*max(v_w(2,:))], '2', 'm/s^2', ...
           true, './figs/noise/noise_v2_w.png');
plot_noise_dist(v_w(2,:), 30, '2', 'm/s^2', true, './figs/noise/noise_v2_w_dist.png');

% Pegando y e os valores maximos para u(t)
sys_u = ss(A, B2, C, D);  % B2 pois queremos estudar apenas u(t)
y_u = lsim(sys_u, u, tu);
y1_u = y_u(:,1);
y2_u = y_u(:,2);
% Procedimento para gerar matriz de variancia
[v_y1_u, v_var_y1_u] = generate_noise(SNR, y1_u);
[v_y2_u, v_var_y2_u] = generate_noise(SNR, y2_u);
% Gerando a matriz de covariancia
V_u = cov(v_y1_u, v_y2_u); 
v_u = [v_y1_u; v_y2_u];
vt_u = timeseries(v_u, tu);
save('./data/measurement_noise_u_data.mat', 'vt_u', '-v7.3')
% Salvando as figuras
%%% Ruido 1
plot_noise(tu, v_u(1,:), [0, 32, 1.1*min(v_u(1,:)), 1.1*max(v_u(1,:))], '1', 'm', ...
           true, './figs/noise/noise_v1_u.png');
plot_noise_dist(v_u(1,:), 30, '1', 'm', true, './figs/noise/noise_v1_u_dist.png');
%%% Ruido 2
plot_noise(tu, v_u(2,:), [0, 32, 1.1*min(v_u(2,:)), 1.1*max(v_u(2,:))], '2', 'm/s^2', ...
           true, './figs/noise/noise_v2_u.png');
plot_noise_dist(v_u(2,:), 30, '2', 'm/s^2', true, './figs/noise/noise_v2_u_dist.png');

%% Projeto dos observadores e do filtro

fprintf('Projetando ganhos dos observadores e filtros...\n')

p = eig(A);  % Polos da planta
C_obs1 = C(1, :);  % Matriz de saida do observador 1
D_obs1 = D(1, :);
C_obs2 = C(2, :);  % Matriz de saida do observador 2
D_obs2 = D(2, :);

%%% Luenberger - POLOS PARA CADA CASO OBTIDO POR TENTATIVA E ERRO
%%%% Entrdada w
%%%%% Observador unico
pu_luenberger_w = 7*real(eig(A)); pu_luenberger_w(2) = 1.25*pu_luenberger_w(1); pu_luenberger_w(4) = 1.25*pu_luenberger_w(3);
Kou_luenberger_w = place(A', C', pu_luenberger_w)';
%%%%% Banco de Observadores
p1_luenberger_w = 2*eig(A);
p2_luenberger_w = 2*eig(A);
Ko1_luenberger_w = place(A', C_obs1', p1_luenberger_w)';
Ko2_luenberger_w = place(A', C_obs2', p2_luenberger_w)';
%%%% Entrada u
%%%%% Observador unico
pu_luenberger_u = 7*real(eig(A)); pu_luenberger_u(2) = 1.25*pu_luenberger_u(1); pu_luenberger_u(4) = 1.25*pu_luenberger_u(3);
Kou_luenberger_u = place(A', C', pu_luenberger_u)';
%%%%% Banco de Observadores
p1_luenberger_u = 5.5*real(eig(A)) + 2.5*imag(eig(A))*1j;
p2_luenberger_u = 5.5*real(eig(A)) + 2.5*imag(eig(A))*1j;
Ko1_luenberger_u = place(A', C_obs1', p1_luenberger_u)';
Ko2_luenberger_u = place(A', C_obs2', p2_luenberger_u)';

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

%%% Filtro passa-baixas
[b_filter, a_filter] = butter(2, 75/(f_sr*pi), 'low');   % wc = 25 + wn2 (padrao)
[H_filter, w_filter] = freqz(b_filter, a_filter);
plot_filter_bode(w_filter, H_filter, f_sr, [0, 75, -3, 0], [0, 75, -90, 0], ...
                 true, './figs/bode/filter_mag_bode.png', './figs/bode/filter_phase_bode.png');

%% Plotando influencia da variacao dos parametros nas saidas

fprintf('Gerando graficos de bode de acordo com variacao de parametros...\n')

percentual_range = linspace(0, 1, 11);
%%% Rainbow
colors = ["#BC0000", "#FF595E", "#FF924C", "#FFCA3A", "#C5CA30", "#8AC926", ...
          "#36949D", "#1982C4", "#4267AC", "#565AA0", "#6A4C93"];
%%% Reversed
% colors = ['#3D3D3D', '#6A4C93', '#565AA0', '#4267AC', '#1982C4', '#36949D', ...
%           '#8AC926', '#C5CA30', '#FF924C', "#FF595E", '#BC0000'];
%%% Blue
% colors = ["#000000", "#00003D", "#000052", "#000079", "#00008F", "#0000B8", ...
%           "#0000FF", "#095DD7", "#429BFA", "#429BFA", "#70B8FF"];

plot_sys_bode_var(mv, ks, bs, mr, kp, bp, 'bs', 0:0.1:1, k1*f0+eps, k2*f0 + 5, colors, ...
                  [0 60 -35 10], [0 60 15 60], [0 60 -80 -30], [0 60 -25 20], true, ...
                  './figs/bode/bode_y1_bs_var_w.png', './figs/bode/bode_y2_bs_var_w.png', ...
                  './figs/bode/bode_y1_bs_var_u.png', './figs/bode/bode_y2_bs_var_u.png');
plot_sys_bode_var(mv, ks, bs, mr, kp, bp, 'ks', percentual_range, k1*f0+eps, k2*f0 + 5, colors, ...
                  [0 60 -35 -5], [0 60 0 50], [0 60 -80 -30], [0 60 -25 10], true, ...
                  './figs/bode/bode_y1_ks_var_w.png', './figs/bode/bode_y2_ks_var_w.png', ...
                  './figs/bode/bode_y1_ks_var_u.png', './figs/bode/bode_y2_ks_var_u.png');

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

sys_hlt_w = ss(A, B1, C, 0);  % Nao precisamos usar B2 (vamos analisar apenas a influencia de w)
sys_hlt_u = ss(A, B2, C, D);  % Nao precisamos usar B2 (vamos analisar apenas a influencia de w)

for sim_case = ['1', '2', '3']  % Cada caso da simulacao
    A_sim_case = eval(sprintf('A_c%s', sim_case));
    B1_sim_case = eval(sprintf('B1_c%s', sim_case));
    B2_sim_case = eval(sprintf('B2_c%s', sim_case));
    C_sim_case = eval(sprintf('C_c%s', sim_case));
    D_sim_case = eval(sprintf('D_c%s', sim_case));
    
    sys_dmg_w = ss(A_sim_case, B1_sim_case, C_sim_case, 0);
    sys_dmg_u = ss(A_sim_case, B2_sim_case, C_sim_case, D_sim_case);

    % Diagrama de bode para cada situacao de falha
    plot_sys_bode(sys_hlt_w, sys_dmg_w, sim_case, k1*f0+eps, k2*f0 + 5, [0, 60, -35, 0], ...
                  [0, 60, 15, 50], true, sprintf('./figs/bode/bode_y1_w_c%s.png', sim_case), ...
                  sprintf('./figs/bode/bode_y2_w_c%s.png', sim_case));
    plot_sys_bode(sys_hlt_u, sys_dmg_u, sim_case, k1*f0+eps, k2*f0 + 5, [0, 60, -80, -30], ...
                  [0, 60, -25, 15], true, sprintf('./figs/bode/bode_y1_u_c%s.png', sim_case), ...
                  sprintf('./figs/bode/bode_y2_u_c%s.png', sim_case));

    % Simulaçao dos observadores
    %%% Entrada w
    [t_luenberger_w, ~, y_luenberger_w, ~, ~, ~, y_hat_obsu_luenberger_w, y1_hat_obs1_luenberger_w, y2_hat_obs2_luenberger_w] = run_sim('./simulations', 'luenberger_w');
    [t_kalman_w, ~, y_kalman_w, ~, ~, ~, y_hat_obsu_kalman_w, y1_hat_obs1_kalman_w, y2_hat_obs2_kalman_w] = run_sim('./simulations', 'kalman_w');
    plot_residue(t_luenberger_w, y_luenberger_w, y_hat_obsu_luenberger_w, y1_hat_obs1_luenberger_w, ...
                 y2_hat_obs2_luenberger_w, y_kalman_w, y_hat_obsu_kalman_w, y1_hat_obs1_kalman_w, ...
                 y2_hat_obs2_kalman_w, sim_case, b_filter, a_filter, true, true, sprintf('./figs/residue/residue1_w_c%s.png', sim_case), ...
                 sprintf('./figs/residue/residue2_w_c%s.png', sim_case));
    print_residue_rmse(t_luenberger_w, y_luenberger_w, y_hat_obsu_luenberger_w, y1_hat_obs1_luenberger_w, ...
                       y2_hat_obs2_luenberger_w, y_kalman_w, y_hat_obsu_kalman_w, y1_hat_obs1_kalman_w, ...
                       y2_hat_obs2_kalman_w, sim_case, 'w', ...
                       b_filter, a_filter)

    %%% Entrada u
    % Simulaçao dos observadores
    [t_luenberger_u, ~, y_luenberger_u, ~, ~, ~, y_hat_obsu_luenberger_u, y1_hat_obs1_luenberger_u, y2_hat_obs2_luenberger_u] = run_sim('./simulations', 'luenberger_u');
    [t_kalman_u, ~, y_kalman_u, ~, ~, ~, y_hat_obsu_kalman_u, y1_hat_obs1_kalman_u, y2_hat_obs2_kalman_u] = run_sim('./simulations', 'kalman_u');
    plot_residue(t_luenberger_u, y_luenberger_u, y_hat_obsu_luenberger_u, y1_hat_obs1_luenberger_u, ...
                 y2_hat_obs2_luenberger_u, y_kalman_u, y_hat_obsu_kalman_u, y1_hat_obs1_kalman_u, ...
                 y2_hat_obs2_kalman_u, sim_case, b_filter, a_filter, true, true, sprintf('./figs/residue/residue1_u_c%s.png', sim_case), ...
                 sprintf('./figs/residue/residue2_u_c%s.png', sim_case));
    print_residue_rmse(t_luenberger_u, y_luenberger_u, y_hat_obsu_luenberger_u, y1_hat_obs1_luenberger_u, ...
                       y2_hat_obs2_luenberger_u, y_kalman_u, y_hat_obsu_kalman_u, y1_hat_obs1_kalman_u, ...
                       y2_hat_obs2_kalman_u, sim_case, 'u', ...
                       b_filter, a_filter)

    % Roda apenas na primeira vez - Exemplo de filtragem de residuos
    if sim_case == '1', plot_denoiser_ex(t_luenberger_w, y_luenberger_w, y1_hat_obs1_luenberger_w, ...
                                         b_filter, a_filter, [0 6 -1.5E-3 1.5E-3], ...
                                         true, './figs/noise/filtering_ex1.png', ...
                                         './figs/noise/filtering_ex2.png'); end  % So na primeira execuçao  
end


%% Melhor estimador e forma de excitaçao (apos analise)

fprintf('Gerando residuos com limiares para o melhor sistema...\n')

best_sim = 'luenberger_u';
best_exct_pos = 'u';
r1_limit = 8.9825E-04;  % Obtido no obs_design...
r2_limit = 0.5740;

[t_best, ~, y_best, ~, ~, ~, y_hat_obsu_best, y1_hat_obs1_best, y2_hat_obs2_best] = run_sim('./simulations', best_sim);

if best_exct_pos == "u"
    y_hat_best = y_hat_obsu_best;
else
    y_hat_best = struct;
    y_hat_best.y1_hat = y1_hat_obs1_best.y1_hat;
    y_hat_best.y2_hat = y2_hat_obs2_best.y2_hat;
end

sim_case = '0';
plot_best_obs_residue(t_best, y_best, y_hat_best, sim_case, r1_limit, ...
    r2_limit, [t_best(1) t_best(ceil(length(t_best)/2)), -r1_limit*1.1, ...
    r1_limit*1.1], [t_best(1) t_best(ceil(length(t_best)/2)), -r2_limit*1.1, ...
    r2_limit*1.1], b_filter, a_filter, false, true, ...
    './figs/residue/residue1_limiar_ex.png', ...
    './figs/residue/residue2_limiar_ex.png');


for sim_case = ['1', '2', '3']
    plot_best_obs_residue(t_best, y_best, y_hat_best, sim_case, r1_limit, ...
    r2_limit, 'auto', 'auto', b_filter, a_filter, true, true, ...
    sprintf('./figs/residue/residue1_limiar_c%s.png', sim_case), ...
    sprintf('./figs/residue/residue2_limiar_c%s.png', sim_case));
end