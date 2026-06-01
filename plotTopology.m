function plotTopology(Nodes,Links,sNodes)
% plotTopology(Nodes,Links,sNodes) - Plots the network topology with
%          servers in blue
%
% Nodes:   a matrix with 2 columns with the (x,y) coordinates of each node
% Links:   a matrix with 2 columns with the end nodes of each link
% sNodes:  a row array with IDs of server nodes (can be an empty row)

    nNodes= size(Nodes,1);
    % Plot the links:
    plot([Nodes(Links(1,1),1) Nodes(Links(1,2),1)],[Nodes(Links(1,1),2) Nodes(Links(1,2),2)],'k-');
    hold on
    for i=2:size(Links,1)
        plot([Nodes(Links(i,1),1) Nodes(Links(i,2),1)],[Nodes(Links(i,1),2) Nodes(Links(i,2),2)],'k-')
    end
    clients= setdiff(1:nNodes,sNodes);
    % Plot the non-selected nodes:
    plot(Nodes(clients,1),Nodes(clients,2),'o','MarkerEdgeColor','k','MarkerFaceColor','w','MarkerSize',10)
    for i=clients
        text(Nodes(i,1),Nodes(i,2),sprintf('%d',i),'HorizontalAlignment','center','Color','k','FontSize',6);
    end
    % Plot the selected nodes:
    plot(Nodes(sNodes,1),Nodes(sNodes,2),'o','MarkerEdgeColor','w','MarkerFaceColor','b','MarkerSize',13)
    for i=sNodes
        text(Nodes(i,1),Nodes(i,2),sprintf('%d',i),'HorizontalAlignment','center','Color','w','FontSize',8);
    end    
    grid on
    hold off
end