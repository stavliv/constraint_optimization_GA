function [best_solution, best_fitness_history, avg_fitness_history] = genetic_algorithm(population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints, varargin)
    % Genetic Algorithm for Traffic Flow Optimization
    % Inputs:
    % - population_size: Number of individuals in the population
    % - num_generations: Number of generations to run the algorithm
    % - mutation_rate: Probability of mutation
    % - elite_rate: Percentage of the population for elitism
    % - V: Total incoming vehicle rate
    % - mode: 'naive' or 'feasible' for constraint handling
    %       Generally 'feasible' will try to enforce the capacity and flow
    %       conservation constraints during initialization, crossover, and mutation,
    %       by using the `distribute_fows` function do distribute the inflow of a
    %       single node to the outgoing edges in a non-violating way.
    %
    %       'naive' on the other hand, does the initialization, crossover, and mutation
    %       without trying to respect the constraints (initialization and mutation
    %       respect the capacity constraints still).
    % - robust: Boolean, true if robust evaluation is enabled
    % - problem_params: Struct containing problem parameters (t, a, c)
    % - node_constraints: Struct containing node-level flow constraints
    % - varargin: Additional parameters for robust evaluation (e.g., V_min, V_max, num_samples)
    % Outputs:
    % - best_solution: The best solution found
    % - best_fitness_history: History of the best fitness across generations
    % - avg_fitness_history: History of the average fitness across generations

    % Parse problem parameters
    t = problem_params.t;
    a = problem_params.a;
    c = problem_params.c;

    % Parse robust evaluation parameters
    if robust
        V_min = varargin{1};
        V_max = varargin{2};
        num_samples = varargin{3};
    end

    % Initialize Population
    population = initialize_population(population_size, length(c), c, mode, V, node_constraints);

    % Initialize arrays to track performance
    best_fitness_history = zeros(num_generations, 1);
    avg_fitness_history = zeros(num_generations, 1);

    for gen = 1:num_generations
        % Evaluate fitness for each individual
        if robust
            fitness = evaluate_population_robust(population, t, a, c, node_constraints, V, V_min, V_max, num_samples);
        else
            fitness = evaluate_population(population, t, a, c, V, node_constraints);
        end

        % Select parents for crossover
        parents = selection(population, fitness);

        % Generate offspring using crossover
        offspring = crossover(parents, mode, c, V, node_constraints);

        % Apply mutation to offspring
        offspring = mutation(offspring, mutation_rate, c, mode, V, node_constraints);

        % Generate next generation with elitism
        population = generate_next_generation(population, offspring, fitness, elite_rate);

        % Track performance
        avg_fitness_history(gen) = mean(fitness);
        [best_fitness, idx] = min(fitness);
        best_solution = population(idx, :);
        best_fitness_history(gen) = best_fitness;

        fprintf('Generation %d: Best Fitness = %.4f, Avg Fitness = %.4f\n', ...
            gen, best_fitness, avg_fitness_history(gen));
    end
end
