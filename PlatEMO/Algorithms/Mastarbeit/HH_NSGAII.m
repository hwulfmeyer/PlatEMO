classdef HH_NSGAII
    methods
        function main(~, Algorithm, Problem, maxFE, i)
            Population = Algorithm.moeas_pops{i};
            [Population, FrontNo, CrowdDis] = HH_NSGAIIEnvironmentalSelection(Population,Problem.N);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,FrontNo,CrowdDis] = HH_NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);

                %% HH: update all Populations
                Algorithm.moeas_pops{i} = Population;
                Algorithm.update_populations(Problem, i, Offspring);
            end
        end

        function update(~, Algorithm, Problem, i, Offspring)
            [Algorithm.moeas_pops{i},~,~] = HH_NSGAIIEnvironmentalSelection([Algorithm.moeas_pops{i},Offspring],Problem.N);
        end
    end
end