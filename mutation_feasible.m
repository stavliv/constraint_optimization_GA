function offspring = mutation_feasible(offspring, mutation_rate, c, V, node_constraints)
    % Inputs:
    % - offspring: Current population of offspring
    % - mutation_rate: Probability of mutation
    % - c: Capacity constraints
    % - V: Total incoming vehicle rate
    % - node_constraints: Node flow conservation constraints
    % Output:
    % - offspring: Mutated offspring population

    [pop_size, N] = size(offspring);

    for i = 1:pop_size
        for node = 1:length(node_constraints)
            % Calculate total inflow to the node
            % Hack first node's inflow to be V
            if node == 1
                inflow_sum = V;
            else
                inflow_sum = sum(offspring(i, node_constraints(node).in));
            end

            out_edges = node_constraints(node).out;

            if ~isempty(out_edges)
                % Correct
                proportions = distribute_flows(node_constraints(node), inflow_sum, c, 'correct', offspring(i, out_edges) / inflow_sum);

                % Convert proportions to actual flows
                offspring(i, out_edges) = proportions * inflow_sum;
            end

            if rand < mutation_rate
                if ~isempty(out_edges)
                    % Apply perturbation mode in distribute_flows
                    proportions = distribute_flows(node_constraints(node), inflow_sum, c, 'perturbation', offspring(i, out_edges) / inflow_sum);
    
                    % Convert proportions to actual flows
                    offspring(i, out_edges) = proportions * inflow_sum;
                end
            end
        end
    end
end

