L = load("L200.txt");
Candidates = load("Candidates.txt");
G = graph(L);
D = distances(G);

N = size(D, 1);
n = 8;
maxNS = 700;
maxSS = 500;

fid = fopen('lpsove.lp','wt');

fprintf(fid, 'min: ');
for s = 1:N
    for i = 1:N
        fprintf(fid, '+ %.4f g%d_%d ', D(s,i), s, i);
    end
end
fprintf(fid, ';\n');

for s = 1:N
    for i = 1:N
        fprintf(fid, '+ g%d_%d - z%d <= 0;\n', s, i, i);
    end
end

for i = 1:N
    fprintf(fid, '+ z%d ', i);
end
fprintf(fid, '= %d;\n', n);

for s = 1:N
    for i = 1:N
        fprintf(fid, '+ g%d_%d ', s, i);
    end
    fprintf(fid, '= 1;\n');
end

for s = 1:N
    for i = 1:N
        if D(s,i) > maxNS
            fprintf(fid, 'g%d_%d = 0;\n', s, i);
        end
    end
end

for i = 1:N
    for j = (i+1):N
        if D(i,j) > maxSS
            fprintf(fid, '+ z%d + z%d <= 1;\n', i, j);
        end
    end
end

% Nós fora dos Candidates não podem ser controladores
for i = 1:N
    if ~ismember(i, Candidates)
        fprintf(fid, 'z%d = 0;\n', i);
    end
end

for i = 1:N
    fprintf(fid, 'Bin z%d;\n', i);
end
for s = 1:N
    for i = 1:N
        fprintf(fid, 'Bin g%d_%d;\n', s, i);
    end
end

fclose(fid);