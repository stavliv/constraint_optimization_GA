function offspring = crossover(parents, mode, c, V, node_constraints)
    % Inputs:
    % - parents: Selected parent individuals
    % - mode: Mode for the crossover.
    %    - 'feasible': will produce soffsprings that respect the capacity
    %    and flow conservation constraints, by using the parameters:
    %    `node_constraints`, `c`, `V` and the `distribute_flows` function.
    %    - 'naive': will produce offsprings that do not necessarily respect
    %    the capacity and flow conservation constraints.
    % - c: Capacity constraints. Needed if `mode` is set to 'feasible'.
    % - V: Total incoming vehicle rate. Needed if `mode` is set to 'feasible'.
    % - node_constraints: Node flow conservation constraints. Needed if `mode` is set to 'feasible'.
    % Output:
    % - offspring: Offspring population

    [pop_size, N] = size(parents);
    offspring = zeros(size(parents));

    for i = 1:2:pop_size
        % Select parents
        parent1 = parents(i, :);
        parent2 = parents(i+1, :);

        % Perform uniform crossover
        alpha = rand;
        child1 = alpha * parent1 + (1 - alpha) * parent2;
        child2 = (1 - alpha) * parent1 + alpha * parent2;

        if strcmp(mode, 'feasible')
            children = [child1; child2];
    
            % Correct each child
            for child_ind = 1:2
                child = children(child_ind, :);
                % Correct every node
                
                for node = 1:length(node_constraints)
                    % Calculate total inflow to the node
                    % Hack first node's inflow to be V
                    if node == 1
                        inflow_sum = V;
                    else
                        inflow_sum = sum(child(node_constraints(node).in));
                    end
    
                    out_edges = node_constraints(node).out;
    
                    if ~isempty(out_edges)
                        % Use unified distribute_flows to get proportions
                        proportions = distribute_flows(node_constraints(node), inflow_sum, c, 'correct', child(out_edges) / inflow_sum);
    
                        % Convert proportions to actual flows
                        child(out_edges) = proportions * inflow_sum;
                    end
                end
    
                offspring(i + child_ind - 1, :) = child;
            end
        elseif strcmp(mode, 'naive')
            offspring(i, :) = child1;
            offspring(i+1, :) = child2;
        end
    end
end
