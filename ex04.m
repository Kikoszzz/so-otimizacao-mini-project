    Nodes = load("Nodes200.txt");
    Links = load("Links200.txt");
    L = load("L200.txt");
    
    nNodes = size(Nodes, 1);
    nLinks = size(Links, 1);
    
    G = graph(L);

    num_nodes = 6;
    
    [sNodes_hc, iterations_hc, runtime_hc] = hc(G, num_nodes, 60);
    [sNodes_sa_hc_1, iterations_sa_hc_1, ~, runtime_sa_hc_1] = sa_hc_def1(G, num_nodes);
    [sNodes_sa_hc_2, iterations_sa_hc_2, runtime_sa_hc_2] = sa_hc_def2(G, num_nodes);
    
    % Practical 6
    runtime_pact6 = 60;
    [sNodes_ms_sa_hc_1, iterations_ms_sa_hc_1] = ms_sa_hc(G, num_nodes, runtime_pact6);
    
    [avgNS_hc, maxNS_hc, maxSS_hc] = ObjectiveSNSP(G, sNodes_hc, true, true, true);
    [avgNS_sa_hc_1, maxNS_sa_hc_1, maxSS_sa_hc_1] = ObjectiveSNSP(G, sNodes_sa_hc_1, true, true, true);
    [avgNS_sa_hc_2, maxNS_sa_hc_2, maxSS_sa_hc_2] = ObjectiveSNSP(G, sNodes_sa_hc_2, true, true, true);
    
    [avgNS_ms_sa_hc_1, maxNS_ms_sa_hc_1, maxSS_ms_sa_hc_1] = ObjectiveSNSP(G, sNodes_ms_sa_hc_1, true, true, true);
    
    % Practical 8
    P_size = 100; q = 0.1; m = 5; k = 2;
    timeLimit_ga = 120;
    
    [sNodes_ga, nPop_ga, runtimeBest_ga] = ga_sns(G, num_nodes, P_size, q, m, k, timeLimit_ga);
    [avgNS_ga, maxNS_ga, maxSS_ga] = ObjectiveSNSP(G, sNodes_ga, true, true, true);
    
    function [sNodes, iterations, runtime] = hc(G, n, time)
    
        t = tic;
        nNodes = numnodes(G);
    
        sNodes = randperm(nNodes, n);
    
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
    
        objVal = avgNS;
        if maxNS > 600, objVal = objVal + 100 * (maxNS - 600); end
        if maxSS > 1000, objVal = objVal + 100 * (maxSS - 1000); end
    
        iterations = 0;
    
        while toc(t) < time
            iterations = iterations + 1;
    
            Others = setdiff(1:nNodes, sNodes);
            Neighbor = [sNodes(randperm(n, n-1)), Others(randperm(nNodes - n, 1))];
    
            [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, Neighbor, true, true, true);
    
            neighVal = avgNS;
            if maxNS > 600, neighVal = neighVal + 100 * (maxNS - 600); end
            if maxSS > 1000, neighVal = neighVal + 100 * (maxSS - 1000); end
    
            if neighVal < objVal
                sNodes = Neighbor;
                objVal = neighVal;
            end
        end
        
        runtime = time;
    end
    
    function [sNodes, objVal, iterations, runtime] = sa_hc_def1(G, n)
        t = tic;
        iterations = 0;
    
        nNodes = numnodes(G);
        sNodes = randperm(nNodes, n); % Greedy randomized pract 7
    
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
        
        objVal = avgNS;
        if maxNS > 600, objVal = objVal + 100 * (maxNS - 600); end
        if maxSS > 1000, objVal = objVal + 100 * (maxSS - 1000); end
    
        improved = true;
    
        while improved
            iterations = iterations + 1;
            improved = false;
    
            Others = setdiff(1:nNodes, sNodes);
    
            bestNeighbor = sNodes;
            bestVal = objVal;
    
            for a = sNodes
                for b = Others
                    Neigh = [setdiff(sNodes,a) b];
    
                    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, Neigh, true, true, true);
    
                    val = avgNS;
                    if maxNS > 600, val = val + 100 * (maxNS - 600); end
                    if maxSS > 1000, val = val + 100 * (maxSS - 1000); end
    
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
    
        runtime = toc(t);
    end
    
    function [sNodes, iterations, runtime] = sa_hc_def2(G, n)
        t = tic;
        iterations = 0;
    
        nNodes = numnodes(G);
        sNodes = randperm(nNodes, n);
    
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
        
        objVal = avgNS;
        if maxNS > 600, objVal = objVal + 100 * (maxNS - 600); end
        if maxSS > 1000, objVal = objVal + 100 * (maxSS - 1000); end
    
        improved = true;
    
        while improved
            iterations = iterations + 1;
            improved = false;
    
            bestNeighbor = sNodes;
            bestVal = objVal;
    
            for a = sNodes
             
                Others = setdiff(neighbors(G, a)', sNodes);
    
                for b = Others
                    Neigh = [setdiff(sNodes,a) b];
    
                    [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, Neigh, true, true, true);
    
                    val = avgNS;
                    if maxNS > 600, val = val + 100 * (maxNS - 600); end
                    if maxSS > 1000, val = val + 100 * (maxSS - 1000); end
    
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
    
        runtime = toc(t);
    end
    
    function [sNodes, iterations] = ms_sa_hc(G, n, time)
        t = tic;
        iterations = 0;
        best = inf;
        sNodes = [];
    
        while toc(t) < time
            [sNodes_curr, curr, ~, ~] = sa_hc_def1(G, n);
            
            if curr < best
                best = curr;
                sNodes = sNodes_curr;
            end
            
            iterations = iterations + 1;
        end
    end
    
    function [sBest, nPop, runtimeBest] = ga_sns(G, n, P_size, q, m, k, timeLimit)
        t = tic;
        nNodes = numnodes(G);
        
        P = zeros(P_size, n + 1);
        for i = 1:P_size
           sol = randperm(nNodes, n);
           P(i, 1:n) = sol;
           P(i, n + 1) = calculateFitness(G, sol);
        end
        
        P = sortrows(P, n + 1);
        
        sBest = P(1, 1:n);
        bestVal = P(1, n + 1);
        runtimeBest = toc(t);
        nPop = 1;
        
        while toc(t) < timeLimit
            nPop = nPop + 1;
            P_prime = zeros(P_size, n + 1);
            
            for i = 1:P_size
                idx1 = randi(P_size, 1, k);
                parent1 = P(min(idx1), 1:n);
                
                idx2 = randi(P_size, 1, k);
                parent2 = P(min(idx2), 1:n);
                
                combined = union(parent1, parent2);
                idx_rand = randperm(length(combined), n);
                offspring = combined(idx_rand);
                
                if rand < q
                    others = setdiff(1:nNodes, offspring);
                    offspring(randi(n)) = others(randi(length(others)));
                end
                
                P_prime(i, 1:n) = offspring;
                P_prime(i, n + 1) = calculateFitness(G, offspring);
            end
            
            P_prime = sortrows(P_prime, n + 1);
            
            new_P = [P(1:m, :); P_prime(1:(P_size - m), :)];
            
            P = sortrows(new_P, n + 1);
            
            if P(1, n + 1) < bestVal
                bestVal = P(1, n + 1);
                sBest = P(1, 1:n);
                runtimeBest = toc(t);
            end
        end
    end
    
    
    function val = calculateFitness(G, sNodes)
        [avgNS, maxNS, maxSS] = ObjectiveSNSP(G, sNodes, true, true, true);
        val = avgNS;
        if maxNS > 600, val = val + 100 * (maxNS - 600); end
        if maxSS > 1000, val = val + 100 * (maxSS - 1000); end
    end

fprintf("Hill Climbing - runtime = %d, iterations = %d\n", runtime_hc, iterations_hc);
fprintf("avgNS = %.2f\t maxNS =  %d\t maxSS = %d\n\n", avgNS_hc, maxNS_hc, maxSS_hc);

fprintf("Steepest Ascent Hill Climbing Definition 1 - runtime = %.2f, iterations = %d\n", runtime_sa_hc_1, iterations_sa_hc_1);
fprintf("avgNS = %.2f\t maxNS =  %d\t maxSS = %d\n\n", avgNS_sa_hc_1, maxNS_sa_hc_1, maxSS_sa_hc_1);

fprintf("Steepest Ascent Hill Climbing Definition 2 - runtime = %.2f, iterations = %d\n", runtime_sa_hc_2, iterations_sa_hc_2);
fprintf("avgNS = %.2f\t maxNS =  %d\t maxSS = %d\n\n", avgNS_sa_hc_2, maxNS_sa_hc_2, maxSS_sa_hc_2);

fprintf("Multi Start Steepest Hill Climbing Definition 1 - runtime = %.2f, iterations = %d\n", runtime_pact6, iterations_ms_sa_hc_1);
fprintf("avgNS = %.2f\t maxNS =  %d\t maxSS = %d\n\n", avgNS_ms_sa_hc_1, maxNS_ms_sa_hc_1, maxSS_ms_sa_hc_1);

fprintf("Genetic Algorithm - runtime best = %.2f, populations = %d\n", runtimeBest_ga, nPop_ga);
fprintf("avgNS = %.2f\t maxNS =  %d\t maxSS = %d\n\n", avgNS_ga, maxNS_ga, maxSS_ga);