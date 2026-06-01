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
alpha = 0.3;

[sBest_grasp, iterations_grasp] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit);
[avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sBest_grasp, true, true, true);

fprintf("GRASP - iterations = %d\n", iterations_grasp);
fprintf("avgNS = %.2f\t maxNS = %d\t maxSS = %d\n\n", avgNS, maxNS, maxSS);


function [sBest, iterations] = grasp(G, Candidates, n, alpha, Wmax, Cmax, timeLimit)
    t = tic;
    iterations = 0;
    sBest = [];
    bestVal = inf;

    while toc(t) < timeLimit
        % Fase 1: construção greedy randomizada
        s = greedyRandomized(G, Candidates, n, alpha);

        % Fase 2: local search (cópia do sa_hc_def1 do ex04, com Wmax e Cmax)
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

        % Avalia cada candidato restante
        costs = zeros(1, nRem);
        for i = 1:nRem
            partial = [sNodes, remaining(i)];
            D = distances(G, partial);       % delays de todos os nós aos candidatos parciais
            minDelays = min(D, [], 1);       % delay mínimo de cada nó ao mais próximo
            costs(i) = mean(minDelays);      % delay médio
        end

        % Constrói a RCL
        cMin = min(costs);
        cMax = max(costs);
        RCL = remaining(costs <= cMin + alpha * (cMax - cMin));

        % Escolhe aleatoriamente da RCL
        sNodes = [sNodes, RCL(randi(length(RCL)))];
    end
end


% Cópia do sa_hc_def1 do ex04, com Wmax e Cmax como parâmetros
function [sNodes, objVal] = sa_hc_def1(G, sNodes, Wmax, Cmax)
    nNodes = numnodes(G);
    
    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
    objVal = avgNS;
    if maxNS > Wmax, objVal = objVal + 100 * (maxNS - Wmax); end
    if maxSS > Cmax, objVal = objVal + 100 * (maxSS - Cmax); end

    improved = true;

    while improved
        improved = false;
        Others = setdiff(1:nNodes, sNodes);
        bestVal = objVal;
        bestNeighbor = sNodes;

        for a = sNodes
            for b = Others
                Neigh = [setdiff(sNodes, a), b];
                
                [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, Neigh, true, true, true);
                val = avgNS;
                if maxNS > Wmax, val = val + 100 * (maxNS - Wmax); end
                if maxSS > Cmax, val = val + 100 * (maxSS - Cmax); end

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