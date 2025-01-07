function offspring = mutation(offspring, mutation_rate, c, mode, V, node_constraints)
    % Inputs:
    % - offspring: Current population of offspring
    % - mutation_rate: Probability of mutation
    % - c: Capacity constraints
    % - mode: Mode for the mutation.
    %    - 'feasible': will produce chromosomes that respect the capacity
    %    and flow conservation constraints, by using the parameters:
    %    `node_constraints`, `c`, `V` and the `distribute_flows` function.
    %    - 'naive': will produce chromosomes that respect the capacity constraints
    %       but do not necessarily respect the  and flow conservation constraints.
    % - V: Total incoming vehicle rate
    % - node_constraints: Node flow conservation constraints
    % Output:
    % - offspring: Mutated offspring population

    [pop_size, N] = size(offspring);

    for i = 1:pop_size

        if strcmp(mode, 'feasible')
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
                    % We need to first correct the node of the offspring,
                    % no matter if this node is going to be mutated, in
                    % case an edge that inflows in this node changed during
                    % this mutation algorithm, and thus we need to
                    % resistribute the flow again.
                    % Basically any change that happens higher up in the
                    % network, creates the need for evry following node to
                    % be ckecked again, since the change caused 
                    % redistribution of the flows higher up in the network,
                    % so redistribution is again needed in the follwing
                    % part of the network.
                    % Note:
                    %   It is subtle but this approach works because of the
                    %   order the node_constraints are defined, it is
                    %   important that when defining node_constraints
                    %   all edges in node_constraints(i).in, are already
                    %   part of some node_constraints(j).out, where j<i.
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
        elseif strcmp(mode, 'naive')
            for idx = 1:N
                if rand < mutation_rate
                    % Apply mutation to the gene
                    offspring(i, idx) = offspring(i, idx) + (rand - 0.5) * 0.1 * c(idx);
                    offspring(i, idx) = max(0, min(offspring(i, idx), c(idx))); % Ensure within bounds
                end
            end
        end
    end
end

