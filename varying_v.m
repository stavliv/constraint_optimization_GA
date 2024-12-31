% Traffic Flow Optimization using Genetic Algorithm
% This script minimizes total traversal time for a traffic network
% Traffic Flow Optimization using Genetic Algorithm (Flow-as-Chromosome Version)

clc; clear; close all;

% Problem Parameters
population_size = 100;       % Population size
num_generations = 500;       % Number of generations
mutation_rate = 0.1;         % Mutation rate
elite_rate = 0.1;           % Percentage of the population for elitism
V = 100;                     % Total incoming vehicle rate
N = 17;                      % Number of roads

% Fixed problem data
% t = [1.25*ones(1,5), 1.5*ones(1,5), ones(1,7)];  % Fixed travel times
t = zeros(N);
a = [1.25*ones(1,5), 1.5*ones(1,5), ones(1,7)];  % Coefficients
c = [54.13, 21.56, 34.08, 49.19, 33.03, 21.84, 29.96, 24.87, 47.24, 33.97, 26.89, 32.76, 39.98, 37.12, 53.83, 61.65, 59.73]; % Capacities

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

% Varying V
% Parameters for robust fitness
V_min = 85;           % Minimum value of V
V_max = 115;          % Maximum value of V
num_samples = 100;     % Number of V samples to approximate expectation

% Initialize arrays to track performance
best_fitness_history = zeros(num_generations, 1); % Best fitness per generation
avg_fitness_history = zeros(num_generations, 1);  % Average fitness per generation
best_solution_history = zeros(num_generations, N); % Best solution per generation

% Initialize Population
population = initialize_feasible_population(population_size, N, c, V, node_constraints);

for gen = 1:num_generations
    % Evaluate fitness for each individual
    fitness = evaluate_population_robust(population, t, a, c, node_constraints, V, V_min, V_max, num_samples);

    % Select parents for crossover
    parents = selection(population, fitness);

    % Generate offspring using feasible crossover
    offspring = crossover_feasible(parents, c, V, node_constraints);

    % Apply feasible mutation to offspring
    offspring = mutation_feasible(offspring, mutation_rate, c, V, node_constraints);

    % Generate next generation with elitism
    population = generate_next_generation(population, offspring, fitness, elite_rate);

    % Track performance
    avg_fitness_history(gen) = mean(fitness);
    [best_fitness, idx] = min(fitness);
    best_solution = population(idx, :);
    best_fitness_history(gen) = best_fitness;
    best_solution_history(gen, :) = best_solution;

    % Display progress
    fprintf('Generation %d: Best Fitness = %.4f, Avg Fitness = %.4f\n', ...
        gen, best_fitness, avg_fitness_history(gen));
end

% Scale the best and average fitness history to V = 100
scaled_best_fitness_history = zeros(num_generations, 1);
scaled_avg_fitness_history = zeros(num_generations, 1);

for gen = 1:num_generations
    % Evaluate fitness for the scaled best solution
    scaled_best_fitness_history(gen) = evaluate_population(best_solution_history(gen, :), t, a, c, V, node_constraints);
end

% Display Results
fprintf('Best Solution (Traffic Flows):\n');
disp(best_solution);
fprintf('Best Fitness (Total Travel Time): %.4f\n', best_fitness);
fprintf('Scaled Best Fitness (Total Travel Time): %.4f\n', scaled_best_fitness_history(num_generations, 1));

% Plot Fitness History
figure;
plot(1:num_generations, best_fitness_history, 'LineWidth', 2, 'DisplayName', 'Best Fitness');
hold on;
plot(1:num_generations, avg_fitness_history, 'LineWidth', 2, 'DisplayName', 'Avg Fitness');
plot(1:num_generations, scaled_best_fitness_history, 'LineWidth', 2, 'DisplayName', 'Scaled Best Fitness (V=100)');
xlabel('Generation');
ylabel('Fitness');
title('Fitness Progress over Generations');
legend('show');
grid on;
hold off;