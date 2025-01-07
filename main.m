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
% Transform the problem to take into account the number of times each edge 
% participates in a valid path from node 1 -> node 9. See more in the
% project report.
%
% The total number of paths that lead from the entry node to the exit node
% is 18, and b shows the number of paths each edge participates in, so devided 
% by 18 we get the weight for each edge.
%
% Our desire is to scale T(i) by b(i) in the fitness function
% Because every t(i) is part of the constant term in the fitness function,
% scaling a(i) by b(i) is essentially the same as scaling T(i) for our
% optimization problem.
%
% In case we want to weight each edge for the number of times it appears in
% possible paths from node the entry node to the exit node, uncomment the
% 2 dollowing lines.
% b = [3, 6, 4, 5, 1, 2, 2, 4, 4, 1, 3, 3, 6, 5, 5, 6, 4] / 18;
% problem_params.a = problem_params.a .* b;

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

% Run the Genetic Algorithm
[best_solution, best_fitness_history, avg_fitness_history] = genetic_algorithm( ...
    population_size, num_generations, mutation_rate, elite_rate, V, mode, robust, problem_params, node_constraints);

% Display Results
fprintf('Best Solution (Traffic Flows):\n');
disp(best_solution);

fprintf('Best Fitness (Total Travel Time): %.4f\n', best_fitness_history(end));

% Plot Fitness History
figure;
plot(1:num_generations, best_fitness_history, 'LineWidth', 2, 'DisplayName', 'Best Fitness');
hold on;
plot(1:num_generations, avg_fitness_history, 'LineWidth', 2, 'DisplayName', 'Average Fitness');
xlabel('Generation');
ylabel('Fitness');
title('Fitness Progress over Generations');
legend('show');
grid on;
hold off;

