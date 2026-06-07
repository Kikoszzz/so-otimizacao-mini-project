Nodes = load("Nodes200.txt");
Links = load("Links200.txt");
L = load("L200.txt");
Candidates = load("Candidates.txt");

nNodes = size(Nodes, 1);
G = graph(L);

n = 8;
Wmax = 700;
Cmax = 500;

D = distances(G);

fid = fopen('problem.lp', 'wt');

fprintf(fid, 'min: ');

first = true;
for s = 1:nNodes
    for ci = 1:length(Candidates)
        i = Candidates(ci);
        if D(s, i) <= Wmax
            if first
                fprintf(fid, '+ %.4f g_%d_%d ', D(s, i), s, i);
                first = false;
            else
                fprintf(fid, '+ %.4f g_%d_%d ', D(s, i), s, i);
            end
        end
    end
end
fprintf(fid, ';\n\n');


% Soma z_i = n  (apenas sobre Candidates)

for ci = 1:length(Candidates)
    i = Candidates(ci);
    fprintf(fid, '+ z_%d ', i);
end
fprintf(fid, '= %d;\n\n', n);

for s = 1:nNodes
    validControllers = [];
    for ci = 1:length(Candidates)
        i = Candidates(ci);
        if D(s, i) <= Wmax
            validControllers(end+1) = i;
        end
    end
    if isempty(validControllers)
        fprintf('AVISO: Nó %d não tem nenhum controlador candidato dentro de Wmax!\n', s);
    else
        for i = validControllers
            fprintf(fid, '+ g_%d_%d ', s, i);
        end
        fprintf(fid, '= 1;\n');
    end
end
fprintf(fid, '\n');

for s = 1:nNodes
    for ci = 1:length(Candidates)
        i = Candidates(ci);
        if D(s, i) <= Wmax
            fprintf(fid, 'g_%d_%d - z_%d <= 0;\n', s, i, i);
        end
    end
end
fprintf(fid, '\n');

for ci = 1:length(Candidates)
    for cj = ci+1:length(Candidates)
        i = Candidates(ci);
        j = Candidates(cj);
        if D(i, j) > Cmax
            fprintf(fid, 'z_%d + z_%d <= 1;\n', i, j);
        end
    end
end
fprintf(fid, '\n');

for ci = 1:length(Candidates)
    i = Candidates(ci);
    fprintf(fid, 'Bin z_%d;\n', i);
end

for s = 1:nNodes
    for ci = 1:length(Candidates)
        i = Candidates(ci);
        if D(s, i) <= Wmax
            fprintf(fid, 'Bin g_%d_%d;\n', s, i);
        end
    end
end

fclose(fid);
fprintf('Ficheiro problem.lp gerado com sucesso.\n');
fprintf('Número de nós: %d\n', nNodes);
fprintf('Número de candidatos: %d\n', length(Candidates));
fprintf('n=%d, Wmax=%d, Cmax=%d\n', n, Wmax, Cmax);