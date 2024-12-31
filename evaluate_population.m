function fitness = evaluate_population(population, t, a, c, V, node_constraints, b)
    % Inputs:
    % - population: Matrix of solutions
    % - t, a, c: Problem parameters
    % - V: Total incoming vehicle rate
    % - node_constraints: Node flow conservation constraints
    % - b: array with the coefficients of each Ti in the fitness function
    % Output:
    % - fitness: Vector of fitness values for the population

    pop_size = size(population, 1);
    fitness = zeros(pop_size, 1);
    

    for i = 1:pop_size
        x = population(i, :);
        penalty = 0;

        % Compute traversal time
        for j = 1:length(x)
            if x(j) >= 0 && x(j) <= c(j)
                fitness(i) = fitness(i) + b(j) * (t(j) + a(j) * (x(j) / (1 - x(j)/c(j))));
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

        % Add penalty to fitness
        fitness(i) = fitness(i) + penalty;
    end
end


