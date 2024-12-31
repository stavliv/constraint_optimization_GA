function new_population = generate_next_generation(population, offsprings, fitness, elite_rate)
    % Generate Next Generation with Elitism
    % Inputs:
    % - population: Current population
    % - offsprings: Newly generated offsprings
    % - fitness: Fitness values for the current population
    % - elite_count: Number of elites
    % Output:
    % - new_population: Next generation population with elitism

    [~, idx] = sort(fitness);  % Sort by fitness
    population_size = size(population, 1);
    elite_count = round(elite_rate * population_size);
    new_population = [population(idx(1:elite_count), :); offsprings(1:end-elite_count, :)];
end