function plotWorstClientPath(Nodes,Links,sNodes,G)
% plotWorstClientPath(Nodes,Links,sNodes,G) - Plots the network topology with
%          servers and links in the worst shortest path in blue 
%
% Nodes:   a matrix with 2 columns with the (x,y) coordinates of each node
% Links:   a matrix with 2 columns with the end nodes of each link
% sNodes:  a row array with IDs of server nodes
% G:       graph of the network 

    sNodes= unique(sNodes);
    nNodes= size(Nodes,1);
    nLinks= size(Links,1);
    Links(nLinks,3)= 0;
    clients= setdiff(1:nNodes,sNodes);
    if ~isempty(sNodes)
        Wcost= -inf;
        Wpath= [];
        for c= clients
            Bcost= inf;
            Bpath= [];
            for s= sNodes
                [path,cost] = shortestpath(G,c,s);
                if cost < Bcost
                    Bcost= cost;
                    Bpath= path;
                end
            end
            if Bcost > Wcost
                Wcost= Bcost;
                Wpath= Bpath;
            end
        end
        for i= 1:length(Wpath)-1
            a1= min(Wpath(i:i+1));
            a2= max(Wpath(i:i+1));
            a= intersect(find(Links(:,1)==a1),find(Links(:,2)==a2));
            if ~isempty(a)
                Links(a,3)= 1;  % Mark as a link in a shortest path
            end
        end
    end
    %plot the links:
    if Links(1,3) == 1  % Links in shortest paths
        plot([Nodes(Links(1,1),1) Nodes(Links(1,2),1)],[Nodes(Links(1,1),2) Nodes(Links(1,2),2)],'b-','LineWidth',2);
    else  % Links not in shortest paths
        plot([Nodes(Links(1,1),1) Nodes(Links(1,2),1)],[Nodes(Links(1,1),2) Nodes(Links(1,2),2)],'k-');
    end
    hold on
    for i=2:nLinks
        if Links(i,3) == 1  %L inks in shortest paths
            plot([Nodes(Links(i,1),1) Nodes(Links(i,2),1)],[Nodes(Links(i,1),2) Nodes(Links(i,2),2)],'b-','LineWidth',2)
        else  % Links not in shortest paths
            plot([Nodes(Links(i,1),1) Nodes(Links(i,2),1)],[Nodes(Links(i,1),2) Nodes(Links(i,2),2)],'k-')
        end
    end
    %plot the non-selected nodes:
    plot(Nodes(clients,1),Nodes(clients,2),'o','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10)
    for i=clients
        text(Nodes(i,1),Nodes(i,2),sprintf('%d',i),'HorizontalAlignment','center','Color','k','FontSize',6);
    end
    % plot the selected nodes:
    plot(Nodes(sNodes,1),Nodes(sNodes,2),'o','MarkerEdgeColor','w','MarkerFaceColor','b','MarkerSize',13)
    for i=sNodes
        text(Nodes(i,1),Nodes(i,2),sprintf('%d',i),'HorizontalAlignment','center','Color','w','FontSize',8);
    end    
    grid on
    hold off
end