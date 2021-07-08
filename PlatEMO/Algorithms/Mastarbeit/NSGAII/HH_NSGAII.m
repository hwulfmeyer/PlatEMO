classdef HH_NSGAII
    methods
        function main(~, Algorithm, Problem, maxFE, k)
            Population = Algorithm.moeas_pops{k};
            [Population, FrontNo, CrowdDis] = HH_NSGAIIEnvironmentalSelection(Population,Problem.N);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,FrontNo,CrowdDis] = HH_NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);

                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end

        function Population = update(~, Population, Problem, Offspring)
            [Population,~,~] = HH_NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);
        end
    end
end