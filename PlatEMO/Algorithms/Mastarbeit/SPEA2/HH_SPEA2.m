classdef HH_SPEA2
% <multi> <real/binary/permutation>
% Strength Pareto evolutionary algorithm 2

%------------------------------- Reference --------------------------------
% E. Zitzler, M. Laumanns, and L. Thiele, SPEA2: Improving the strength
% Pareto evolutionary algorithm, Proceedings of the Conference on
% Evolutionary Methods for Design, Optimization and Control with
% Applications to Industrial Problems, 2001, 95-100.
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
            %% Generate random population
            Population = Algorithm.moeas_pops{k};
            Fitness    = HH_SPEA2_CalFitness(Population.objs);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,Fitness);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,Fitness] = HH_SPEA2_EnvironmentalSelection([Population,Offspring],Problem.N);
            
                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end
        
        function Population = update(~, Population, Problem, Offspring)
            [Population,~] = HH_SPEA2_EnvironmentalSelection([Population,Offspring],Problem.N);
        end
    end
end