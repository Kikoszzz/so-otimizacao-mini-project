%% Script Definitivo de Otimização - Simulação e Otimização
clear all; close all; clc;

fprintf('=========================================================\n');
fprintf('   Carregando os Ficheiros de Suporte e Configuração     \n');
fprintf('=========================================================\n');

% 1. Carregar Dados Reais da Rede de 200 nós
Nodes = load('Nodes200.txt');      
Links = load('Links200.txt');      
L = load('L200.txt');              
candidates = load('Candidates.txt'); 

if iscolumn(candidates)
    candidates = candidates';
end

nNodes = size(Nodes,1);
G = graph(L); % Construir o Grafo através da matriz de adjacência L

% Parâmetros Oficiais do Mini-Projeto
n = 8;          % Número de controladores
Wmax = 700;     % Limite Switch-Controlador
Cmax = 500;     % Limite Inter-Controlador
timeLimit = 60; % Limite estrito de 60 segundos por corrida

fprintf('Rede de %d nós e %d candidatos azuis carregada com sucesso.\n\n', nNodes, numel(candidates));

%% =======================================================================
%  MENU DE SELEÇÃO NA CONSOLA
% =======================================================================
fprintf('Escolha o algoritmo que deseja executar:\n');
fprintf('  [1] - f2 (Pesquisa Local com Penalização)\n');
fprintf('  [2] - f3 (Random Search com Rejeição Pura)\n');
fprintf('  [3] - GRASP (Metaheurística Oficial - Construtivo + Local)\n');
fprintf('  [4] - GA (Metaheurística Oficial - Algoritmo Genético)\n');

opcao = input('\nIntroduza o número da sua opção [1-4]: ');

sNodes = [];
nomeAlgoritmo = '';

switch opcao
    case 1
        nomeAlgoritmo = 'Pesquisa Local (f2)';
        fprintf('\nA executar %s por %d segundos...\n', nomeAlgoritmo, timeLimit);
        sNodes = f2(G, n, timeLimit, candidates);
        
    case 2
        nomeAlgoritmo = 'Random Search (f3)';
        fprintf('\nA executar %s por %d segundos...\n', nomeAlgoritmo, timeLimit);
        sNodes = f3(G, n, timeLimit, candidates);
        
    case 3
        nomeAlgoritmo = 'GRASP Oficial';
        r = 5; % Tamanho da RCL (Parâmetro a afinar nos teus testes)
        fprintf('\nA executar %s (r=%d) por %d segundos...\n', nomeAlgoritmo, r, timeLimit);
        [sNodes, bestAvg, nIter, runtime] = GRASP(G, L, candidates, n, Wmax, Cmax, r, timeLimit);
        fprintf('Iterações completadas pelo GRASP: %d\n', nIter);
        
    case 4
        nomeAlgoritmo = 'Algoritmo Genético (GA) Oficial';
        popSize = 100; mutProb = 0.1; elitismM = 5; tournK = 2; % Setup padrão
        fprintf('\nA executar %s por %d segundos...\n', nomeAlgoritmo, timeLimit);
        [sNodes, bestAvg, nPop, runtime] = GA(G, L, candidates, n, Wmax, Cmax, popSize, mutProb, elitismM, tournK, timeLimit);
        fprintf('Gerações evoluídas pelo GA: %d\n', nPop);
        
    otherwise
        error('Opção inválida. Execute o script novamente e selecione um número de 1 a 4.');
end

%% =======================================================================
%  APRESENTAÇÃO DOS RESULTADOS E GRÁFICOS
% =======================================================================
if ~isempty(sNodes)
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
    
    fprintf('\n================ RESULTADOS FINAIS: %s =================\n', upper(nomeAlgoritmo));
    fprintf('Melhores Nós Selecionados: [%s]\n', num2str(sNodes));
    fprintf('Atraso Médio (avgNS):       %.4f (Minimizar)\n', avgNS);
    fprintf('Atraso Máximo (maxNS/Wmax): %.4f (Deve ser <= 700)\n', maxNS);
    fprintf('Atraso Inter-Ctrl (maxSS/Cmax): %.4f (Deve ser <= 500)\n', maxSS);
    fprintf('========================================================================\n');
    
    % Desenhar os Gráficos das tuas Support Functions
    figure(1); plotClientPaths(Nodes, Links, sNodes, G);
    figure(2); plotWorstClientPath(Nodes, Links, sNodes, G);
    figure(3); plotWorstServerPath(Nodes, Links, sNodes, G);
else
    fprintf('\n[AVISO]: O algoritmo não conseguiu encontrar nenhuma solução válida no tempo limite.\n');
end


%% =======================================================================
%  FUNÇÕES AUXILIARES LOCAIS (f2 e f3)
% =======================================================================
function sNodes = f2(G, n, time, candidates)
    t = tic;
    nCands = numel(candidates);
    idx = randperm(nCands, n);
    sNodes = candidates(idx);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
    objVal = avgNS;
    if maxNS > 700, objVal = objVal + 10000 * (maxNS - 700); end
    if maxSS > 500, objVal = objVal + 10000 * (maxSS - 500); end
    best = objVal;
    while toc(t) < time
        Others = setdiff(candidates, sNodes);
        nOthers = numel(Others);
        if nOthers == 0, break; end
        Neigh = [sNodes(randperm(n, n-1)), Others(randperm(nOthers, 1))];
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, Neigh, true, true, true);
        objVal = avgNS;
        if maxNS > 700, objVal = objVal + 10000 * (maxNS - 700); end
        if maxSS > 500, objVal = objVal + 10000 * (maxSS - 500); end
        if objVal < best
            sNodes = Neigh;
            best = objVal;
        end
    end
end

function sNodes = f3(G, n, time, candidates)
    t = tic;
    nCands = numel(candidates);
    best = inf; sNodes = []; counter = 0;
    while toc(t) < time
        counter = counter + 1;
        idx = randperm(nCands, n);
        aux = candidates(idx);
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, aux, true, true, true);
        if avgNS < best && maxNS <= 700 && maxSS <= 500 && maxNS ~= -1
            sNodes = aux;
            best = avgNS;
        end
    end
    fprintf('Iterações do f3 (Random Search): %d\n', counter);
end