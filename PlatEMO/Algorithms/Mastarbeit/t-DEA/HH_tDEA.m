classdef HH_tDEA
% <multi/many> <real/binary/permutation>
% theta-dominance based evolutionary algorithm

%------------------------------- Reference --------------------------------
% Y. Yuan, H. Xu, B. Wang, and X. Yao, A new dominance relation-based
% evolutionary algorithm for many-objective optimization, IEEE Transactions
% on Evolutionary Computation, 2016, 20(1): 16-37.
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
            %% Generate the reference points and random population
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population    = Algorithm.moeas_pops{k};
            [z,znad]      = deal(min(Population.objs),max(Population.objs));

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool = randi(Problem.N,1,Problem.N);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,z,znad] = HH_tDEA_EnvironmentalSelection([Population,Offspring],W,Problem.N,z,znad);
                
                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end
         
        function Population = update(~, Population, Problem, Offspring)
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            [z,znad]      = deal(min(Population.objs),max(Population.objs));
            [Population,~,~] = HH_tDEA_EnvironmentalSelection([Population,Offspring],W,Problem.N,z,znad);
        end
    end
end