clear; close all; clc

set(0,'DefaultLineLineWidth', 1.5, ...
    'DefaultAxesFontName', 'Latin Modern Math', ...
    'DefaultAxesFontSize', 14);  

%% Parametros gerais da simulaçao

% Condiçoes iniciais
% CI = [1; 1; 1; 1];
CI = [0; 0; 0; 0];

%% Parametros da suspensao da quanser

fprintf('Definindo parametros...\n')

mv = 2.45;  % [mv] = kg --> Massa de 1/4 do veiculo
ks = 900;   % [ks] = N/m --> Constante elastica da suspensao
bs = 7.5;   % [bs] = Ns/m --> Coeficiente de amortecimento da suspensao
mr = 1;     % [mr] = kg --> Massa do eixo-roda
kp = 1250;  % [kp] = N/m --> Constante elastica do pneu
bp = 5;     % [bp] = Ns/m --> Coeficiente de amortecimento do pneu

%% Matrizes do sistema

fprintf('Definindo matrizes do sistema...\n')

% Sistema saudavel (A sem variaçao)
A = [0 1 0 -1; -ks/mv -bs/mv 0 bs/mv; 0 0 0 1; ks/mr bs/mr -kp/mr -(bs+bp)/mr];
B1 = [0; 0; -1; bp/mr];
B2 = [0; 1/mv; 0; -1/mr];
B = [B1 B2];
C = [1 0 0 0; 0 1 0 0];
% C = [0 0 1 0; 0 0 0 1];  % APENAS PARA TESTE! COMENTAR
D = 0;

% Sistemas com dano
%%% Caso 1: Perda do amortecimento da suspensao de 50%
bs_ = 0.5*bs;
A_c1 = [0 1 0 -1; -ks/mv -bs_/mv 0 bs_/mv; 0 0 0 1; ks/mr bs_/mr -kp/mr -(bs_+bp)/mr];
%%% Caso 2: Perda do amortecimento da suspensao de 100% (sem amortecimento)
bs_ = 0;
A_c2 = [0 1 0 -1; -ks/mv -bs_/mv 0 bs_/mv; 0 0 0 1; ks/mr bs_/mr -kp/mr -(bs_+bp)/mr];
%%% Caso 3: Perda da rigidez da mola da suspensao de 50% 
ks_ = 0.5*ks;
A_c3 = [0 1 0 -1; -ks_/mv -bs/mv 0 bs/mv; 0 0 0 1; ks_/mr bs/mr -kp/mr -(bs+bp)/mr];
%%% Caso 4 (teste): Perda de amortecimento da suspensao e da rigidez da mola
ks_ = 0;
bs_ = 0;
A_c4 = [0 1 0 -1; -ks_/mv -bs/mv 0 bs/mv; 0 0 0 1; ks_/mr bs/mr -kp/mr -(bs+bp)/mr];

%% Projeto do observador

fprintf('Projetando ganhos dos observadores...\n')

p = eig(A);  % Polos da planta
C_obs1 = C(1, :);  % Matriz de saida do observador 1
C_obs2 = C(2, :);  % Matriz de saida do observador 2

%%% Luenberger
%%%% Polos desejados para o observador
p_luenberger = 4*p;
%%%% Observador 1
Ko1_luenberger = place(A', C_obs1', p_luenberger)';
%%%% Observador 2
Ko2_luenberger = place(A', C_obs2', p_luenberger)';

%%% UIO - Heloi
%%%% Polos desejados para o observador  - TODO: Problema! E*C = 0 --> Igual a Luenberger
p_uio = 4*p;
%%%% Observador 1
[N_obs1, L_obs1, G_obs1, E_obs1, Ko1_uio] = project_uio(A, B1, B2, C_obs1, p_uio);  % APENAS w(t) como sinal desconhecido
% [N_obs1, L_obs1, G_obs1, E_obs1, Ko1_uio] = project_uio(A, B, 0, C_obs1, p_uio);  % AMBOS w(t) e u(t) como sinais desconhecidos
%%%% Observador 2
[N_obs2, L_obs2, G_obs2, E_obs2, Ko2_uio] = project_uio(A, B1, B2, C_obs2, p_uio);  % APENAS w(t) como sinal desconhecido
% [N_obs2, L_obs2, G_obs2, E_obs2, Ko2_uio] = project_uio(A, B, 0, C_obs2, p_uio);  % AMBOS w(t) e u(t) como sinais desconhecidos

%%% Kalman
% TODO 

%% Sinal de Chirp

fprintf('Gerando sinal de chirp...\n')

%%% Chirp 
% Parametros para gerar o sinal
As = 0.2;
T0 = 16;
f0 = 1/T0;
k1 = 0*(1/f0);  % Fica mais claro do que k1 = 0*T0
k2 = 6*(1/f0);
dt = 2.5E-5;  % Para que a gente consiga visualizar bem
t = 0:dt:T0;
N = 2;  % Numero de periodos
% N = 1;  % Numero de periodos

% Sinal gerado
[w, t] = generate_chirp(As, T0, k1, k2, t, N);

% Exportando para arquivo
wt = timeseries(w, t);
save('../data/chirp_data.mat', 'wt', '-v7.3')

% Salvando as figuras
%%% No tempo
fig_chirp = plot_chirp(t, w, [t(1), t(end), -As*1.1, As*1.1]);
fig_chirp.Visible = 'off';
print(fig_chirp,'-dpng','../figs/chirp.png', '-r600');
%%% Na frequencia
ii = ceil(length(t)/2);
w_ = w(1:ii);  % Fazendo assim pois dois concatenados da bug...
fig_mag = plot_fspec(w_, length(w_)*10, dt, [[k1*f0, k2*f0+2, -20, 1]; [k1*f0, k2*f0+2, -185, 185]], true);
fig_mag.Visible = 'off';
print(fig_mag,'-dpng','../figs/chirp_mag.png', '-r600');

%% Ruido de mediçao e processo

fprintf('Gerando sinal de ruido...\n')

% Pegando y e os valores maximos
sys = ss(A, B1, C, D);  % B1 pois queremos estudar apenas w(t)
y = lsim(sys, w, t);
y1 = y(:,1);
y2 = y(:,2);

% Procedimento para gerar matriz de variancia
SNR = 30;  % 20dB --> Sinal eh 100x mais potente que o ruido
% % SNR = 30;  % 30dB --> Sinal eh 1000x mais potente que o ruido
[v_y1, v_var_y1] = generate_noise(SNR, y1);
[v_y2, v_var_y2] = generate_noise(SNR, y2);

% Gerando a matriz de covariancia
V = cov(v_var_y1, v_var_y2); 
v = [v_y1; v_y2];
 
vt = timeseries(v, t);
save('../data/measurement_noise.mat', 'vt', '-v7.3')

% Salvando as figuras
%%% Ruido 1
fig_v1 = plot_noise(t, v(1,:), [0, 32, 1.1*min(v(1,:)), 1.1*max(v(1,:))], '1', 'm');
fig_v1.Visible = 'off';
print(fig_v1,'-dpng','../figs/noise_v1.png', '-r600');
fig_v1_dist = plot_noise_dist(v(1,:),30,'1','m');
fig_v1_dist.Visible = 'off';
print(fig_v1_dist,'-dpng','../figs/noise_v1_dist.png', '-r600');
%%% Ruido 2
fig_v2 = plot_noise(t, v(2,:), [0, 32, 1.1*min(v(2,:)), 1.1*max(v(2,:))], '2', 'm/s');
fig_v2.Visible = 'off';
print(fig_v2,'-dpng','../figs/noise_v2.png', '-r600');
fig_v2_dist = plot_noise_dist(v(2,:),30,'2','m/s');
fig_v2_dist.Visible = 'off';
print(fig_v2_dist,'-dpng','../figs/noise_v2_dist.png', '-r600');
