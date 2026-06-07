Nodes = load("Nodes200.txt");
Links = load("Links200.txt");
L = load("L200.txt");
Candidates = load("Candidates.txt");

nNodes = size(Nodes, 1);
nLinks = size(Links, 1);
G = graph(L);

n = 8;
Wmax = 700;
Cmax = 500;
timeLimit = 60;

% Valores a testar
alpha_values  = [0.1, 0.3, 0.5, 0.7, 0.9];
Psize_values  = [50, 100, 150, 200, 250];
q_values      = [0.05, 0.10, 0.20, 0.30, 0.40];
m_values      = [1, 3, 5, 7, 10];
k_values      = [1, 2, 3, 4, 5];

% Settings base para o GA (mantidos fixos enquanto se varia outro)
alpha_base = 0.3;
Psize_base = 150; q_base = 0.15; m_base = 3; k_base = 2;

fileID = fopen('settings_test.txt', 'w');

%% GRASP — variar alpha
fprintf(fileID, '========== GRASP: variar alpha ==========\n');
for i = 1:length(alpha_values)
    alpha = alpha_values(i);
    [sBest, iterations] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest, true, true, true);
    fprintf(fileID, 'alpha=%.2f | iterations=%d | avgNS=%.2f | maxNS=%d | maxSS=%d\n', ...
        alpha, iterations, avgNS, maxNS, maxSS);
end

%% GA — variar P_size
fprintf(fileID, '\n========== GA: variar P_size (q=%.2f, m=%d, k=%d) ==========\n', q_base, m_base, k_base);
for i = 1:length(Psize_values)
    P_size = Psize_values(i);
    [sBest, nPop, runtimeBest] = ga(G, Candidates, n, P_size, q_base, m_base, k_base, Wmax, Cmax, timeLimit);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest, true, true, true);
    fprintf(fileID, 'P_size=%d | populations=%d | runtimeBest=%.2f | avgNS=%.2f | maxNS=%d | maxSS=%d\n', ...
        P_size, nPop, runtimeBest, avgNS, maxNS, maxSS);
end

%% GA — variar q
fprintf(fileID, '\n========== GA: variar q (P_size=%d, m=%d, k=%d) ==========\n', Psize_base, m_base, k_base);
for i = 1:length(q_values)
    q = q_values(i);
    [sBest, nPop, runtimeBest] = ga(G, Candidates, n, Psize_base, q, m_base, k_base, Wmax, Cmax, timeLimit);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest, true, true, true);
    fprintf(fileID, 'q=%.2f | populations=%d | runtimeBest=%.2f | avgNS=%.2f | maxNS=%d | maxSS=%d\n', ...
        q, nPop, runtimeBest, avgNS, maxNS, maxSS);
end

%% GA — variar m
fprintf(fileID, '\n========== GA: variar m (P_size=%d, q=%.2f, k=%d) ==========\n', Psize_base, q_base, k_base);
for i = 1:length(m_values)
    m = m_values(i);
    [sBest, nPop, runtimeBest] = ga(G, Candidates, n, Psize_base, q_base, m, k_base, Wmax, Cmax, timeLimit);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest, true, true, true);
    fprintf(fileID, 'm=%d | populations=%d | runtimeBest=%.2f | avgNS=%.2f | maxNS=%d | maxSS=%d\n', ...
        m, nPop, runtimeBest, avgNS, maxNS, maxSS);
end

%% GA — variar k
fprintf(fileID, '\n========== GA: variar k (P_size=%d, q=%.2f, m=%d) ==========\n', Psize_base, q_base, m_base);
for i = 1:length(k_values)
    k = k_values(i);
    [sBest, nPop, runtimeBest] = ga(G, Candidates, n, Psize_base, q_base, m_base, k, Wmax, Cmax, timeLimit);
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest, true, true, true);
    fprintf(fileID, 'k=%d | populations=%d | runtimeBest=%.2f | avgNS=%.2f | maxNS=%d | maxSS=%d\n', ...
        k, nPop, runtimeBest, avgNS, maxNS, maxSS);
end

fclose(fileID);
disp('Testes concluídos. Resultados em settings_test.txt');






% ==================================================
% ==================================================
% ==================================================




function [sBest, iterations] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit)
    t = tic;
    iterations = 0;
    sBest = [];
    bestVal = inf;

    while toc(t) < timeLimit
        s = greedyRandomized(G, Candidates, n, alpha);
        [s, sVal] = sa_hc_def1(G, s, Candidates, Wmax, Cmax);

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
            [avgNS, ~, ~] = ObjectiveSNSP(G, partial, true, false, false);
            costs(i) = avgNS;
        end

        cMin = min(costs);
        cMax = max(costs);
        RCL = remaining(costs <= cMin + alpha * (cMax - cMin));

        sNodes = [sNodes, RCL(randi(length(RCL)))];
    end
end

function [sNodes, objVal] = sa_hc_def1(G, sNodes, Candidates, Wmax, Cmax)
    objVal = calculateFitness(G, sNodes, Wmax, Cmax);

    improved = true;

    while improved
        improved = false;
        Others = setdiff(Candidates, sNodes);
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