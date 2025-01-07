function population = initialize_population(population_size, N, c, mode, V, node_constraints)
    % Inputs:
    % - population_size: Number of individuals in the population
    % - N: Number of roads (chromosome length)
    % - c: Capacity constraints
    % - mode: Mode for the initialization of the population.
    %    - 'feasible': will produce chromosomes that respect the capacity
    %    and flow conservation constraints, by using the parameters:
    %    `node_constraints`, `c`, `V` and the `distribute_flows` function.
    %    - 'naive': will produce chromosomes that respect the capacity constraints
    %       but do not necessarily respect the  and flow conservation constraints.
    % - V: Total incoming vehicle rate. Needed if `mode` is set to 'feasible'.
    % - node_constraints: Node flow conservation constraints. Needed if `mode` is set to 'feasible'.
    % Output:
    % - population: Initialized feasible population

    population = zeros(population_size, N);

    for i = 1:population_size
        individual = zeros(1, N);

        if strcmp(mode, 'feasible')
            for node = 1:length(node_constraints)
                % Calculate total inflow to the node
                % Hack first node's inflow to be V
                if node == 1
                    inflow_sum = V;
                else
                    inflow_sum = sum(individual(node_constraints(node).in));
                end
    
                out_edges = node_constraints(node).out;
    
                if ~isempty(out_edges)
                    % Generate proportions using the 'ground_up' mode
                    proportions = distribute_flows(node_constraints(node), inflow_sum, c, 'ground_up', []);
    
                    % Convert proportions to actual flows
                    individual(out_edges) = proportions * inflow_sum;
                end
            end
        elseif strcmp(mode, 'naive')
            % Randomly generate values for each road within capacity
            individual = rand(1, N) .* c;
        end

        population(i, :) = individual;
    end
end

