function parents = selection(population, fitness)
    % Tournament selection
    % Inputs:
    % - population: Current population matrix
    % - fitness: Fitness values for each individual
    % Output:
    % - parents: Selected individuals for crossover

    population_size = size(population, 1);
    parents = zeros(size(population));
    for i = 1:population_size
        idx1 = randi([1, population_size]);
        idx2 = randi([1, population_size]);
        if fitness(idx1) < fitness(idx2)
            parents(i, :) = population(idx1, :);
        else
            parents(i, :) = population(idx2, :);
        end
    end
end