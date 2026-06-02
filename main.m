% Carregamento de Dados Base
Nodes = load("Nodes200.txt");
Links = load("Links200.txt");
L = load("L200.txt");
Candidates = load("Candidates.txt");
nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
G = graph(L);

% Parâmetros Fixos
n = 8;
Wmax = 700;
Cmax = 500;
timeLimit = 60;
P_size = 100; m = 5; k = 2;

% Abertura do ficheiro para registo de resultados
fileID = fopen('resultados_execucao.txt', 'w');
fprintf(fileID, "=================== RELATÓRIO DE EXECUÇÃO ===================\n\n");

% Ciclo Principal - 12 Execuções
for run = 1:12
    % Cálculo dos parâmetros variáveis a cada duas runs
    % run 1-2: bloco=0 -> alpha=0.2, q=0.05
    % run 3-4: bloco=1 -> alpha=0.3, q=0.10
    % run 5-6: bloco=2 -> alpha=0.4, q=0.15, etc.
    block = floor((run - 1) / 2);
    alpha = 0.2 + (block * 0.1);
    q = 0.05 + (block * 0.05);
    
    % Imprimir progresso na consola do MATLAB
    fprintf("A executar Run %d/12 (alpha = %.2f, q = %.2f)...\n", run, alpha, q);
    
    % Escrita do cabeçalho da run no ficheiro
    fprintf(fileID, "---------------------------------------------------------\n");
    fprintf(fileID, "RUN %d - Parâmetros: GRASP alpha = %.2f | GA q = %.2f\n", run, alpha, q);
    fprintf(fileID, "---------------------------------------------------------\n");
    
    % Execução do GRASP
    [sBest_grasp, iterations_grasp] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit);
    [avgNS_grasp, maxNS_grasp, maxSS_grasp] = ObjectiveSNSP(G, sBest_grasp, true, true, true);
    
    % Escrita dos resultados do GRASP no ficheiro
    fprintf(fileID, "GRASP -\tIterations: %d\n", iterations_grasp);
    fprintf(fileID, "\tAvgNS: %.2f\tMaxNS: %d\tMaxSS: %d\n", avgNS_grasp, maxNS_grasp, maxSS_grasp);
    fprintf(fileID, "\tMelhor Solução: [%s]\n\n", num2str(sBest_grasp));
    
    % Execução do GA
    [sBest_ga, nPop_ga, runtimeBest_ga] = ga(G, Candidates, n, P_size, q, m, k, Wmax, Cmax, timeLimit);
    [avgNS_ga, maxNS_ga, maxSS_ga] = ObjectiveSNSP(G, sBest_ga, true, true, true);
    
    % Escrita dos resultados do GA no ficheiro
    fprintf(fileID, "GA -\tPopulations: %d\tRuntimeBest: %.2f s\n", nPop_ga, runtimeBest_ga);
    fprintf(fileID, "\tAvgNS: %.2f\tMaxNS: %d\tMaxSS: %d\n", avgNS_ga, maxNS_ga, maxSS_ga);
    fprintf(fileID, "\tMelhor Solução: [%s]\n\n", num2str(sBest_ga));
end

% Fecho do ficheiro de texto
fclose(fileID);
fprintf("Processo concluído com sucesso. Resultados guardados em 'resultados_execucao.txt'.\n");

% =========================================================================
% FUNÇÕES AUXILIARES (Mantidas de acordo com a implementação original)
% =========================================================================

function [sBest, iterations] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit)
    t = tic;
    iterations = 0;
    sBest = [];
    bestVal = inf;
    while toc(t) < timeLimit
        s = greedyRandomized(G, Candidates, n, alpha);
        [s, sVal] = sa_hc_def1(G, s, Wmax, Cmax);
        if sVal < bestVal
            bestVal = sVal;
            sBest = s;
        end
        iterations = iterations + 1;
    end
end

function sNodes = greedyRandomized(G, Candidates, n, alpha)
    sNodes = [];
    for step = 1:n
        remaining = setdiff(Candidates, sNodes);
        nRem = length(remaining);
        costs = zeros(1, nRem);
        for i = 1:nRem
            partial = [sNodes, remaining(i)];
            D = distances(G, partial);
            minDelays = min(D, [], 1);
            costs(i) = mean(minDelays);
        end
        cMin = min(costs);
        cMax = max(costs);
        RCL = remaining(costs <= cMin + alpha * (cMax - cMin));
        sNodes = [sNodes, RCL(randi(length(RCL)))];
    end
end

function [sNodes, objVal] = sa_hc_def1(G, sNodes, Wmax, Cmax)
    nNodes = numnodes(G);
    objVal = calculateFitness(G, sNodes, Wmax, Cmax);
    improved = true;
    while improved
        improved = false;
        Others = setdiff(1:nNodes, sNodes);
        bestVal = objVal;
        bestNeighbor = sNodes;
        for a = sNodes
            for b = Others
                Neigh = [setdiff(sNodes, a), b];
                val = calculateFitness(G, Neigh, Wmax, Cmax);
                if val < bestVal
                    bestVal = val;
                    bestNeighbor = Neigh;
                end
            end
        end
        if bestVal < objVal
            sNodes = bestNeighbor;
            objVal = bestVal;
            improved = true;
        end
    end
end

function [sBest, nPop, runtimeBest] = ga(G, Candidates, n, P_size, q, m, k, Wmax, Cmax, timeLimit)
    t = tic;
    nCandidates = length(Candidates);
    P = zeros(P_size, n+1);
    for i = 1:P_size
        sol = Candidates(randperm(nCandidates, n));
        P(i, 1:n) = sol;
        P(i, n+1) = calculateFitness(G, sol, Wmax, Cmax);
    end
    P = sortrows(P, n+1);
    sBest = P(1, 1:n);
    bestVal = P(1, n+1);
    runtimeBest = toc(t);
    nPop = 1;
    while toc(t) < timeLimit
        nPop = nPop + 1;
        P_prime = zeros(P_size, n+1);
        for i = 1:P_size
            idx1 = randi(P_size, 1, k);
            parent1 = P(min(idx1), 1:n);
            idx2 = randi(P_size, 1, k);
            parent2 = P(min(idx2), 1:n);
            combined = union(parent1, parent2);
            offspring = combined(randperm(length(combined), n));
            if rand < q
                others = setdiff(Candidates, offspring);
                offspring(randi(n)) = others(randi(length(others)));
            end
            P_prime(i, 1:n) = offspring;
            P_prime(i, n+1) = calculateFitness(G, offspring, Wmax, Cmax);
        end
        P_prime = sortrows(P_prime, n+1);
        new_P = [P(1:m, :); P_prime(1:(P_size-m), :)];
        P = sortrows(new_P, n+1);
        if P(1, n+1) < bestVal
            bestVal = P(1, n+1);
            sBest = P(1, 1:n);
            runtimeBest = toc(t);
        end
    end
end

function val = calculateFitness(G, sNodes, Wmax, Cmax)
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
    val = avgNS;
    if maxNS > Wmax, val = val + 100 * (maxNS - Wmax); end
    if maxSS > Cmax, val = val + 100 * (maxSS - Cmax); end
end