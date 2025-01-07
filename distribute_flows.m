function proportions = distribute_flows(node_constraints, inflow_sum, c, mode, current_values)
    % Unified distribute_flows function for both "Proportion" and "Flow" chromosome cases.
    % Inputs:
    % - node_constraints: Struct for the current node with fields:
    %   - .out: Outgoing edge indices
    % - inflow_sum: Total inflow to the node
    % - c: Capacity vector for all edges
    % - mode: 'ground_up', 'perturbation', or 'correct'
    % - current_values: current proportions, needed in 'perturbation', and
    %   'correct' mode.
    % Output:
    % - proportions: Proportion of inflow assigned to each outgoing edge

    % Get outgoing edges and their capacities
    out_edges = node_constraints.out;
    edge_capacities = c(out_edges);
    num_edges = length(out_edges);

    % Initialize proportions
    proportions = zeros(1, num_edges);

    if strcmp(mode, 'ground_up')
        % Mode: Create new proportions from scratch
        random_proportions = rand(1, num_edges);

        sum_proportions = sum(random_proportions);
        if sum_proportions > 0
            random_proportions = random_proportions / sum_proportions; % Normalize to sum to 1
        else
            random_proportions = (1 / num_edges) * ones(1, num_edges); % Equal split if all zeros
        end
        proportions = random_proportions; % Proportions sum to 1

    elseif strcmp(mode, 'perturbation')
        % Mode: Adjust existing proportions with perturbation
        perturbation = (rand(1, num_edges) - 0.5) * 0.1; % ±5% perturbation
        new_proportions = current_values + perturbation;
        new_proportions = max(new_proportions, 0); % Ensure non-negative
        sum_proportions = sum(new_proportions);
        if sum_proportions > 0
            proportions = new_proportions / sum_proportions; % Normalize to sum to 1
        else
            proportions = (1 / num_edges) * ones(1, num_edges); % Equal split if all zeros
        end

    elseif strcmp(mode, 'correct')
        % Mode: Normalize current values to sum to 1 and adjust for capacity constraints
        proportions = current_values / sum(current_values); % Normalize to sum to 1
    end

    % Scale proportions to respect capacity constraints
    % Calculate room
    if inflow_sum > 0
        max_capacity_proportion = edge_capacities / inflow_sum;
        room = max_capacity_proportion - proportions;
        
        % Identify positive and negative room
        positive_indices = find(room > 0);
        negative_indices = find(room < 0);
        
        positive_room = room(positive_indices);
        negative_room = room(negative_indices);
    
        % Redistribution
        for neg_idx = 1:length(negative_indices)
            neg_value = abs(negative_room(neg_idx)); % Amount to redistribute
            for pos_idx = 1:length(positive_indices)
                if neg_value == 0
                    break; % If no more to redistribute
                end
                if positive_room(pos_idx) > 0
                    transferable = min(neg_value, positive_room(pos_idx)); % How much can be transferred
                    negative_room(neg_idx) = negative_room(neg_idx) + transferable; % Decrease negative room
                    positive_room(pos_idx) = positive_room(pos_idx) - transferable; % Decrease positive room
                    neg_value = neg_value - transferable; % Update remaining to redistribute
                end
            end
        end
        
        % Update proportions with redistributed values
        for idx = 1:length(positive_indices)
            proportions(positive_indices(idx)) = max_capacity_proportion(positive_indices(idx)) - positive_room(idx);
        end
        for idx = 1:length(negative_indices)
            proportions(negative_indices(idx)) = max_capacity_proportion(negative_indices(idx)) + negative_room(idx);
        end
    end

end