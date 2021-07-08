classdef HH_IBEA
% <multi/many> <real/binary/permutation>
% Indicator-based evolutionary algorithm
% kappa --- 0.05 --- Fitness scaling factor

%------------------------------- Reference --------------------------------
% E. Zitzler and S. Kunzli, Indicator-based selection in multiobjective
% search, Proceedings of the International Conference on Parallel Problem
% Solving from Nature, 2004, 832-842.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    methods
        function main(~, Algorithm, Problem, maxFE, k)
            %% Parameter setting
            kappa = 0.05;

            %% Generate random population
            Population = Algorithm.moeas_pops{k};

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,-CalFitness(Population.objs,kappa));
                Offspring  = OperatorGA(Population(MatingPool));
                Population = HH_IBEA_EnvironmentalSelection([Population,Offspring],Problem.N,kappa);
            
                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end
        
        function Population = update(~, Population, Problem, Offspring)
            kappa = 0.05;
            Population = HH_IBEA_EnvironmentalSelection([Population,Offspring],Problem.N,kappa);
        end
    end
end