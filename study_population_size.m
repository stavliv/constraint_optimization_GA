clc; clear; close all;

% Problem Parameters
num_generations = 200;       % Number of generations
elite_rate = 0.02;           % Percentage of the population for elitism
V = 100;                     % Total incoming vehicle rate
N = 17;                      % Number of roads
mutation_rate = 0.1;         % Fixed mutation rate

% Fixed problem data
t = zeros(N);  % Fixed travel times
a = [1.25*ones(1,5), 1.5*ones(1,5), ones(1,7)];  % Coefficients
c = [54.13, 21.56, 34.08, 49.19, 33.03, 21.84, 29.96, 24.87, 47.24, 33.97, 26.89, 32.76, 39.98, 37.12, 53.83, 61.65, 59.73]; % Capacities

% Population size range to study
population_sizes = [50, 100, 200, 500]; % Different population sizes to test
results_population = struct();

% Define node-level constraints
node_constraints(1).in = []; % Node 1 has no incoming edges
node_constraints(1).out = [1, 2, 3, 4]; % Outgoing edges x1, x2, x3, x4

node_constraints(2).in = [1]; % Incoming edge x1
node_constraints(2).out = [5, 6]; % Outgoing edges x5, x6

node_constraints(3).in = [2]; % Incoming edge x2
node_constraints(3).out = [7, 8]; % Outgoing edges x8, x7

node_constraints(4).in = [4]; % Incoming edge x4
node_constraints(4).out = [9, 10]; % Outgoing edges x9, x10

node_constraints(5).in = [3, 8, 9]; % Incoming edges x3, x8, x9
node_constraints(5).out = [11, 12, 13]; % Outgoing edges x11, x12, x13

node_constraints(6).in = [6, 7, 13]; % Incoming edges x6, x7, x13
node_constraints(6).out = [14, 15]; % Outgoing edges x14, x15

node_constraints(7).in = [5, 14]; % Incoming edges x5, x14
node_constraints(7).out = [16]; % Outgoing edge x16

node_constraints(8).in = [10, 11]; % Incoming edges x10, x11
node_constraints(8).out = [17]; % Outgoing edge x17

node_constraints(9).in = [12, 15, 16, 17]; % Incoming edges x12, x15, x16, x17
node_constraints(9).out = []; % No outgoing edges

% Loop through population sizes
for p_idx = 1:length(population_sizes)
    population_size = population_sizes(p_idx);
    fprintf('\nTesting Population Size: %d\n', population_size);

    % Initialize Population
    population = initialize_feasible_population(population_size, N, c, V, node_constraints);
    
    % Initialize arrays to track performance
    best_fitness_history = zeros(num_generations, 1);
    avg_fitness_history = zeros(num_generations, 1);

    for gen = 1:num_generations
        % Evaluate fitness for each individual
        fitness = evaluate_population(population, t, a, c, V, node_constraints);
    
        % Select parents for crossover
        parents = selection(population, fitness);
    
        % Generate offspring using feasible crossover
        offspring = crossover_feasible(parents, c, V, node_constraints);
    
        % Apply feasible mutation to offspring
        offspring = mutation_feasible(offspring, mutation_rate, c, V, node_constraints);
    
        % Generate next generation with elitism
        population = generate_next_generation(population, offspring, fitness, elite_rate);
        
        % Track average and best fitness for the generation
        avg_fitness_history(gen) = mean(fitness);
        [best_fitness, idx] = min(fitness);
        best_solution = population(idx, :);
        best_fitness_history(gen) = best_fitness;
    end
    
    % Store results for this population size
    results_population(p_idx).population_size = population_size;
    results_population(p_idx).best_fitness_history = best_fitness_history;
    results_population(p_idx).avg_fitness_history = avg_fitness_history;
    results_population(p_idx).final_best_fitness = best_fitness;
    results_population(p_idx).final_best_solution = best_solution;
end

% Plot Results for Population Size Study
figure;
hold on;
for p_idx = 1:length(population_sizes)
    plot(1:num_generations, results_population(p_idx).best_fitness_history, 'LineWidth', 2, ...
        'DisplayName', sprintf('Population Size %d', population_sizes(p_idx)));
end
xlabel('Generation');
ylabel('Best Fitness');
title('Effect of Population Size on Best Fitness');
legend('show');
grid on;
hold off;
