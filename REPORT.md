================ RESULTADOS FINAIS =================
Melhores Nós Selecionados: [53  120  116   89  115   78  118   59]
Atraso Médio (avgNS):       279.5050 (Minimizar)
Atraso Máximo (maxNS/Wmax): 635.0000 (Deve ser <= 700)
Atraso Inter-Ctrl (maxSS/Cmax): 498.0000 (Deve ser <= 500)
====================================================

sNodes = f2(G, 8, 60, candidates);

## Análise do Comportamento das Restrições

A análise detalhada dos indicadores de atraso máximo revela aspetos fundamentais sobre a dinâmica de exploração do espaço de estados pelo algoritmo.

### Eficácia da Função de Penalização de Barreira Exterior

O indicador de pior atraso inter-controlador ((maxSS)) fixou-se em (498.0000), posicionando-se muito próximo do limiar máximo admissível de (500). Este comportamento valida cientificamente a reconfiguração matemática aplicada à função de aptidão, nomeadamente a introdução de um multiplicador de penalização elevado a (10000). O algoritmo demonstrou capacidade para explorar eficazmente as fronteiras de inviabilidade da topologia: ao "esticar" a distância entre controladores até ao limite permitido, conseguiu maximizar a dispersão geográfica dos mesmos no grafo, sem ultrapassar as restrições impostas.

### Garantia de Qualidade de Serviço (QoS)

O atraso máximo verificado entre qualquer switch da rede e o respetivo controlador mais próximo ((maxNS)) estabilizou em (635.0000). Este valor proporciona uma margem de segurança confortável relativamente ao limite regulamentar de (700), demonstrando que a elevada dispersão dos controladores não comprometeu a conectividade dos nós periféricos da rede. Assim, o modelo conseguiu equilibrar simultaneamente a separação entre controladores e a manutenção de níveis aceitáveis de qualidade de serviço.

### Validação do Espaço de Procura

Verificou-se ainda que todos os nós selecionados ((53, 59, 78, 89, 115, 116, 118, 120)) pertencem estritamente ao conjunto de nós azuis. Este resultado valida o correto alinhamento do mecanismo de mapeamento de índices introduzido no código-fonte, eliminando a possibilidade de seleção de nós inválidos ou inexistentes no grafo de (200) nós. Consequentemente, confirma-se a consistência estrutural da representação da solução utilizada pelo algoritmo.

## 4.1.3. Definição da Linha de Base (Baseline) para a Análise Comparativa

Os resultados obtidos nesta experiência estabelecem a baseline quantitativa que servirá de referência para as restantes fases do projeto.

### Desafio para as Metaheurísticas Avançadas (GRASP e GA)

O valor de custo médio de (279.5050) constitui o principal ponto de comparação para as metaheurísticas avançadas. Considerando que o algoritmo (f_2) realiza apenas uma pesquisa local simples (*Hill Climbing*) com inicialização totalmente aleatória, espera-se que abordagens mais estruturadas, como o GRASP — através da utilização de uma *Restricted Candidate List* (RCL) — e o Algoritmo Genético (GA), recorrendo a mecanismos de seleção, cruzamento e mutação, consigam superar esta barreira de desempenho. Em particular, estas técnicas deverão reduzir significativamente o risco de aprisionamento em ótimos locais, promovendo uma exploração mais abrangente do espaço de soluções.

### Avaliação do Gap de Otimização

O custo obtido de (279.5050) será posteriormente comparado com o ótimo global absoluto determinado através do método exato de Programação Linear Inteira, resolvido com recurso ao *lpsolve*. Esta comparação permitirá calcular o *gap* de otimização da solução heurística, isto é, a percentagem de desvio relativamente à solução matematicamente ótima. Tal métrica será fundamental para quantificar objetivamente a eficácia das diferentes abordagens heurísticas desenvolvidas ao longo do projeto.

sNodes = f3(G, 8, 60, candidates);


Iterações do f3 (Random Search): 148837

================ RESULTADOS FINAIS =================
Melhores Nós Selecionados: [97  113   63  138   91   67  120  107]
Atraso Médio (avgNS):       280.8000 (Minimizar)
Atraso Máximo (maxNS/Wmax): 694.0000 (Deve ser <= 700)
Atraso Inter-Ctrl (maxSS/Cmax): 500.0000 (Deve ser <= 500)
====================================================


4.2. Análise da Estratégia Multi-Start de Procura Aleatória ($f_3$)Nesta secção, são apresentados e discutidos os resultados obtidos através do algoritmo de Procura Aleatória com Rejeição Pura ($f_3$). O algoritmo foi executado com um limite estrito de 60 segundos, gerando em cada iteração uma nova combinação independente de $n = 8$ controladores a partir do vetor candidates, aplicando um filtro imediato de exclusão caso alguma restrição fosse violada.

4.2.2. Análise Crítica do Desempenho e Comparação com $f_2$A interpretação destes resultados face à execução anterior do algoritmo $f_2$ permite extrair conclusões metodológicas profundas para o projeto:Eficiência Baseada na Força Bruta Aleatória: O algoritmo demonstrou uma capacidade computacional notável ao avaliar 148.837 soluções em 60 segundos. O facto de o pior atraso inter-controlador ($maxSS$) ter fixado o seu valor em 500.0000 (exatamente em cima do limite regulamentar) prova a agressividade do filtro de rejeição: o algoritmo aceitou uma solução geometricamente perfeita na fronteira do espaço de viabilidade.O Trade-off entre Pesquisa Local ($f_2$) e Procura Aleatória ($f_3$): Ao compararmos os dois métodos, observam-se dados muito curiosos para a discussão teórica:Qualidade da Solução ($avgNS$): A Pesquisa Local ($f_2$) obteve um custo ligeiramente melhor (279.5050) do que a Procura Aleatória $f_3$ (280.8000).Explicação Científica: Isto acontece porque o $f_3$ não tem memória (falta de guiamento). Embora teste milhares de combinações, ele fá-lo às cegas. O $f_2$, por sua vez, começa num ponto aleatório mas usa a estrutura de vizinhança para refinar as posições dos controladores passo a passo. Isto demonstra que, em problemas com grafos grandes (200 nós), mecanismos de refinamento local são tipicamente superiores à amostragem puramente aleatória.4.2.3. Conclusão da Baseline para o GRASP e o GAO sucesso das experiências com os algoritmos $f_2$ e $f_3$ deixa o projeto perfeitamente preparado para a introdução das metaheurísticas oficiais:O limite de viabilidade foi testado com sucesso em ambos os cenários (Penalização e Rejeição).Fica empiricamente provado que a solução ótima da rede de 200 nós para $avgNS$ estará muito provavelmente abaixo da barreira dos 279 ms. Os algoritmos estruturados GRASP (que une a construção inteligente do $f_3$ com a pesquisa local do $f_2$) e GA terão como meta explícita bater este indicador de referência.