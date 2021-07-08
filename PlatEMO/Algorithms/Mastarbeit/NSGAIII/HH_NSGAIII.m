classdef HH_NSGAIII
    methods
        function main(~, Algorithm, Problem, maxFE, k)
            %% Generate the reference points and random population
            [Z,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population    = Algorithm.moeas_pops{k};
            Zmin          = min(Population(all(Population.cons<=0,2)).objs,[],1);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,sum(max(0,Population.cons),2));
                Offspring  = OperatorGA(Population(MatingPool));
                Zmin       = min([Zmin;Offspring(all(Offspring.cons<=0,2)).objs],[],1);
                Population = HH_NSGAIIIEnvironmentalSelection([Population,Offspring],Problem.N,Z,Zmin);
            
                %%HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end

        function Population = update(~, Population, Problem, Offspring)
            [Z,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Zmin       = min(Population(all(Population.cons<=0,2)).objs,[],1);
            Zmin       = min([Zmin;Offspring(all(Offspring.cons<=0,2)).objs],[],1);
            Population = HH_NSGAIIIEnvironmentalSelection([Population,Offspring],Problem.N,Z,Zmin);
        end
    end
end

