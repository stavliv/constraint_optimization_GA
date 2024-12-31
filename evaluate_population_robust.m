function fitness = evaluate_population_robust(population, t, a, c, node_constraints, V_original, V_min, V_max, num_samples)
    % Fitness function used to optimize for the expected total T
    % when V is a random variable.
    %
    % Assumes V follows a uniform distribution in [V_min, V_max].
    % The expected value of T is computed in a Monte Carlo like
    % approach sampling 'n_samples' times.
    % 
    % Inputs:
    % - population: Matrix of candidate solutions (flows)
    % - t, a, c: Problem parameters
    % - V_min, V_max: Range of V (total flow)
    % - V_original: V in which the population is represented with.
    % - num_samples: Number of samples to approximate the expectation
    % Output:
    % - fitness: Average traversal time for each solution

    population_size = size(population, 1);
    fitness = zeros(population_size, 1);

    for i = 1:population_size
        total_traversal_time = 0;
        for s = 1:num_samples
            % Sample V uniformly in [V_min, V_max]
            V = V_min + (V_max - V_min) * rand;

            % Scale solution to match sampled V,
            % so flow conservation constraints hold,
            % since incoming flow now is V and not V_original
            x = population(i, :) * V / V_original;

            traversal_time = 0;
            penalty = 0;
            % Compute traversal time
            for j = 1:length(x)
                if x(j) >= 0 && x(j) <= c(j)
                    traversal_time = traversal_time + t(j) + a(j) * (x(j) / (1 - x(j)/c(j)));
                else
                    penalty = penalty + 1e6 * max(0, x(j) - c(j)); % Penalty for capacity violations
                end
            end
    
            % Add penalties for node flow conservation
            for node = 1:length(node_constraints)
                % Hack first node's inflow to be V
                if node == 1
                    inflow = V;
                else
                    inflow = sum(x(node_constraints(node).in));
                end  
                % Hack last node's outflow to be V
                if node == length(node_constraints)
                    outflow = V;
                else
                    outflow = sum(x(node_constraints(node).out));
                end
    
                if abs(inflow - outflow) > 1e-03
                    penalty = penalty + 1e6 * abs(inflow - outflow); % Penalize imbalance
                end
            end

            traversal_time = traversal_time + penalty;
            total_traversal_time = total_traversal_time + traversal_time;
        end
        % Average traversal time over all samples
        fitness(i) = total_traversal_time / num_samples;
    end
