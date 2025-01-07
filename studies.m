clc; clear; close all;

% Parameter that controls whether the evaluation function will evaluation
% function will take into account a range for V, and thus having a robust
% solution for differnr values of V.
% Set to false for assignemnt 2.
robust = false; 
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
num_generations = 200;
V = 100;

% Study 1: Varying Population Size
mutation_rate = 0.1;
elite_rate = 0.1;
population_sizes = [50, 100, 200, 500];

figure;
hold on;
for population_size = population_sizes
    [~, best_fitness_history, ~] = genetic_algorithm(population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints);
    plot(1:num_generations, best_fitness_history, 'DisplayName', sprintf('Population Size: %d', population_size));
end
xlabel('Generation');
ylabel('Best Fitness');
title('Effect of Population Size on GA Performance');
legend('show');
grid on;
hold off;

% Study 2: Varying Mutation Rate
population_size = 100;
elite_rate = 0.1;
mutation_rates = [0.01, 0.05, 0.1, 0.2];

figure;
hold on;
for mutation_rate = mutation_rates
    [~, best_fitness_history, ~] = genetic_algorithm(population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints);
    plot(1:num_generations, best_fitness_history, 'DisplayName', sprintf('Mutation Rate: %.2f', mutation_rate));
end
xlabel('Generation');
ylabel('Best Fitness');
title('Effect of Mutation Rate on GA Performance');
legend('show');
grid on;
hold off;

% Study 3: Varying Elite Rate
population_size = 100;
mutation_rate = 0.1;
elite_rates = [0.01, 0.05, 0.1, 0.2];

figure;
hold on;
for elite_rate = elite_rates
    [~, best_fitness_history, ~] = genetic_algorithm(population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints);
    plot(1:num_generations, best_fitness_history, 'DisplayName', sprintf('Elite Rate: %.2f', elite_rate));
end
xlabel('Generation');
ylabel('Best Fitness');
title('Effect of Elite Rate on GA Performance');
legend('show');
grid on;
hold off;
