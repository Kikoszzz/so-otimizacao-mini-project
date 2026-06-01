function [avgNS,maxNS,maxSS]= ObjectiveSNSP(G,sNodes,run1,run2,run3)
% [avgNS,maxNS,maxSS]= ObjectiveSNSP(G,sNodes,run1,run2,run3)
%
% INPUTS:
%   G      -  graph of the network
%   sNodes -  a row array with server node IDs
%   run1   -  boolean indicating the request to compute avgNS
%   run2   -  boolean indicating the request to compute maxNS
%   run3   -  boolean indicating the request to compute maxSS
%
% OUTPUTS:
%   avgNS -  avg. shortest path length from each node to its closest server
%            - returns [] if run1 is FALSE
%            - returns -1 if run1 is TRUE and input data is invalid
%   maxNS -  max. shortest path length from any node to its closest server
%            - returns [] if run2 is FALSE
%            - returns -1 if run2 is TRUE and input data is invalid
%   maxSS -  max. shortest path length between any pair of servers
%            - returns [] if run3 is FALSE
%            - returns -1 if run3 is TRUE and input data is invalid
 
    nNodes= numnodes(G);
    avgNS= []; maxNS= []; maxSS= [];
    if (length(sNodes)<1 || max(sNodes)>nNodes || min(sNodes)<1 || length(unique(sNodes))<length(sNodes))
        if run1, avgNS= -1; end
        if run2, maxNS= -1; end
        if run3, maxSS= -1; end
        return
    end
    if run1 || run2
        clients= setdiff(1:nNodes,sNodes);
        dist= distances(G,sNodes,clients);
        if length(sNodes)>1, dist= min(dist); end
        if run1, avgNS= sum(dist)/nNodes; end
        if run2, maxNS= max(dist); end
    end
    if run3
        if length(sNodes)>1
            maxSS= max(max(distances(G,sNodes,sNodes)));
        else
            maxSS= 0;
        end
    end
end