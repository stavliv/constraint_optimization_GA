clc; clear; close all;

% Parameter that controls whether the evaluation function will evaluation
% function will take into account a range for V, and thus having a robust
% solution for differnr values of V.
% Set to true for assignemnt 3.
robust = true; 
% Problem Parameters
problem_params.t = zeros(17, 1); % Fixed travel times
problem_params.a = [1.25*ones(1,5), 1.5*ones(1,5), ones(1,7)]; % Coefficients
problem_params.c = [54.13, 21.56, 34.08, 49.19, 33.03, 21.84, 29.96, 24.87, 47.24, 33.97, 26.89, 32.76, 39.98, 37.12, 53.83, 61.65, 59.73]; % Capacities

% Node constraints
node_constraints(1).in = []; node_constraints(1).out = [1, 2, 3, 4];
node_constraints(2).in = [1]; node_constraints(2).out = [5, 6];
node_constraints(3).in = [2]; node_constraints(3).out = [7, 8];
node_constraints(4).in = [4]; node_constraints(4).out = [9, 10];
node_constraints(5).in = [3, 8, 9]; node_constraints(5).out = [11, 12, 13];
node_constraints(6).in = [6, 7, 13]; node_constraints(6).out = [14, 15];
node_constraints(7).in = [5, 14]; node_constraints(7).out = [16];
node_constraints(8).in = [10, 11]; node_constraints(8).out = [17];
node_constraints(9).in = [12, 15, 16, 17]; node_constraints(9).out = [];

% Mode for constraint handling: 'naive' or 'feasible'.
% Defaults to 'feasible', to check the performance of the 'naive' approach
% just set `mode = 'naive';`.
mode = 'feasible'; 
% Parameters for Genetic Algorithm
population_size = 100;       % Number of individuals in the population
num_generations = 200;       % Number of generations
mutation_rate = 0.1;         % Probability of mutation
elite_rate = 0.1;            % Percentage of the population for elitism
V = 100;                     % Total incoming vehicle rate

% Robust evaluation parameters
V_min = 85;                  % Minimum value of V (-15% of original V)
V_max = 115;                 % Maximum value of V (+15% of original V)
num_samples = 100;           % Number of samples for robust evaluation
                             % The bigger the more representative the
                             % evalluation, but expensive

% Run the Genetic Algorithm with robust evaluation
[best_solution, best_fitness_history, avg_fitness_history] = genetic_algorithm( ...
    population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints, V_min, V_max, num_samples);

% Display Results
fprintf('Best Solution (Traffic Flows):\n');
disp(best_solution);

fprintf('Fitness (robust) of best solution: %.4f\n', best_fitness_history(end));

fitness_at_original_v = evaluate_population( ...
    best_solution, problem_params.t, problem_params.a, problem_params.c, V, node_constraints);
fprintf('Fitness (evaluated only on V=100) of best solution: %.4f\n', fitness_at_original_v);

% Plot Fitness History
figure;
plot(1:num_generations, best_fitness_history, 'LineWidth', 2, 'DisplayName', 'Best Fitness');
xlabel('Generation');
ylabel('Fitness');
title('Fitness Progress over Generations with Robust Evaluation');
legend('show');
grid on;

figure;
plot(1:num_generations, avg_fitness_history, 'LineWidth', 2, 'DisplayName', 'Average Fitness');
xlabel('Generation');
ylabel('Fitness');
title('Fitness Progress over Generations with Robust Evaluation');
legend('show');
grid on;
