function offspring = crossover_feasible(parents, c, V, node_constraints)
    % Inputs:
    % - parents: Selected parent individuals
    % - c: Capacity constraints
    % - V: Total incoming vehicle rate
    % - node_constraints: Node flow conservation constraints
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
        children = [child1; child2];

        for child_ind = 1:2
            child = children(child_ind, :);
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
    end
end
