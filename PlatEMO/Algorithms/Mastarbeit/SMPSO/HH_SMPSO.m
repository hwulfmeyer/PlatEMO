classdef HH_SMPSO < handle
% <multi> <real>
% Speed-constrained multi-objective particle swarm optimization

%------------------------------- Reference --------------------------------
% A. J. Nebro, J. J. Durillo, J. Garcia-Nieto, C. A. Coello Coello, F.
% Luna, and E. Alba, SMPSO: A new PSO-based metaheuristic for
% multi-objective optimization, Proceedings of the IEEE Symposium on
% Computational Intelligence in Multi-Criteria Decision-Making, 2009,
% 66-73.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2021 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------
    properties
        Pbest;
        Gbest;
    end
    methods
        function main(obj, Algorithm, Problem, maxFE, k)
            %% Generate random population
            Population = Algorithm.moeas_pops{k};
            if isempty(obj.Pbest)
                obj.Pbest  = Population;
            else
                obj.Pbest  = UpdatePbest(obj.Pbest,Population);
            end
            [obj.Gbest,CrowdDis] = UpdateGbest(Population,Problem.N);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                Population           = HH_SMPSO_Operator(Population,obj.Pbest,obj.Gbest(TournamentSelection(2,Problem.N,-CrowdDis)));
                [obj.Gbest,CrowdDis] = UpdateGbest([obj.Gbest,Population],Problem.N);
                obj.Pbest            = UpdatePbest(obj.Pbest,Population);
                
                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end

        function Population = update(obj, Population, Problem, Offspring)
            Population       = HH_SMPSO_Operator([Population, Offspring],obj.Pbest,obj.Gbest(TournamentSelection(2,Problem.N,-CrowdDis)));
            [obj.Gbest,~]    = UpdateGbest([obj.Gbest,Population],Problem.N);
            obj.Pbest        = UpdatePbest(obj.Pbest,Population);
        end
    end
end