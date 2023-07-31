clear; clc

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

%% Projeto do observador

fprintf('Projetando ganhos dos observadores...\n')

p = eig(A);  % Polos da planta
C_obs1 = C(1, :);  % Matriz de saida do observador 1
C_obs2 = C(2, :);  % Matriz de saida do observador 2

%%% Luenberger
%%%% Polos desejados para o observador
p_obs = 4*p;
%%%% Observador 1
Ko1_luenberger = place(A', C_obs1', p_obs)';
%%%% Observador 2
Ko2_luenberger = place(A', C_obs2', p_obs)';

%%% UIO - Heloi
%%%% Polos desejados para o observador  --- ENTENDER PORQUE ESTA DANDO ERRADO E REFAZER
% p_obs = 4*p;
% %%%% Observador 1
% E_obs1 = -B1*pinv(C_obs1*B1);
% H_obs1 = eye(length(E_obs1)) + E_obs1*C_obs1;
% A1_obs1 = H_obs1*A;
% Ko1_uio = place(A1_obs1', C_obs1', p_obs)';
% N_obs1 = A1_obs1 - Ko1_uio*C_obs1;
% L_obs1 = Ko1_uio - N_obs1*E_obs1;
% %%%% Observador 2
% E_obs2 = -B1*pinv(C_obs2*B1);
% H_obs2 = eye(length(E_obs2)) + E_obs2*C_obs2;
% A1_obs2 = H_obs2*A;
% Ko2_uio = place(A1_obs2', C_obs2', p_obs)';
% N_obs2 = A1_obs2 - Ko2_uio*C_obs2;
% L_obs2 = Ko2_uio - N_obs2*E_obs2;
% --------------------------------------------------------------------------------------
%%% UIO - Chen
%%%% Polos desejados para o observador  --- ENTENDER PORQUE ESTA DANDO ERRADO E REFAZER
% p_obs = 4*p;
% if rank(C_obs1*B1) == rank(B1)
%     H_obs1 = B1*inv((C_obs1*B1)'*(C_obs1*B1))*(C_obs1*B1)';
%     T_obs1 = eye(length(H_obs1)) - H_obs1*C_obs1;
%     A1_obs1 = T_obs1*A;
%     K1_obs1 = place(A1_obs1', C_obs1', p_obs)';
%     F_obs1 = A1_obs1 - K1_obs1*C_obs1;
%     Ko1_uio = K1_obs1 + F_obs1*H_obs1;
% else
%     fprintf("!!! IMPOSSIVEL PROJETAR UIO !!!")
% end

%%% Kalman
% TODO 

%% Sinal de Chirp

fprintf('Gerando sinal de chirp...\n')

%%% Chirp 
% Parametros para gerar o sinal
As = 0.2;
f0 = 1/16;
T0 = 1/f0;
k1 = 0*(1/f0);
k2 = 6*(1/f0);
dt = 2.5E-6;  % Para que a gente consiga visualizar bem
t_range = 0:dt:T0;
N = 2;  % Numero de periodos

% Sinal gerado
w = [];
t = [];
for i=1:N
    tt = (i-1)*T0 + t_range;
    ww = chirp(As, f0, k1, k2, t_range);
    w = [w, ww];
    t = [t, tt];
end

% Apenas para testes (COMENTAR DEPOIS)
% w(t >= 5) = 0;

% Exportando para arquivo
wt = timeseries(w, t);
save('../data/chirp_data.mat', 'wt', '-v7.3')

%% Ruido de mediçao e processo

fprintf('Gerando sinal de ruido...\n')

% W = 10;  % Variancia - Como determinar?
V = [1E-6 0; 0 1E-3];  % Variancia - Como determinar?

% w_ = sqrt(W)*randn(1, length(t));
v_ = sqrt(V)*randn(2, length(t));
 
% w_t = timeseries(w_, t);
% save('../data/process_noise.mat', 'w_t', '-v7.3')
v_t = timeseries(v_, t);
save('../data/measurement_noise.mat', 'v_t', '-v7.3')