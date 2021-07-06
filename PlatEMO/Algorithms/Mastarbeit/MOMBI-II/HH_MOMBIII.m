classdef HH_MOMBIII
% <multi/many> <real/binary/permutation>
% Many objective metaheuristic based on the R2 indicator II
% alpha   ---   0.5 --- Threshold of variances
% epsilon --- 0.001 --- Tolerance threshold
% record  ---     5 --- The record size of nadir vectors

%------------------------------- Reference --------------------------------
% R. Hernandez Gomez and C. A. Coello Coello, Improved metaheuristic based
% on the R2 indicator for many-objective optimization, Proceedings of the
% Annual Conference on Genetic and Evolutionary Computation, 2015, 679-686.
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
            alpha = 0.5;
            epsilon = 0.001;
            recordSize = 5;

            %% Generate random population
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population = Algorithm.moeas_pops{k};
            % Ideal and nadir points
            zmin = min(Population.objs,[],1);
            zmax = max(Population.objs,[],1);
            % For storing the nadir vectors of a few generations
            Record = repmat(zmax,recordSize,1);
            % For storing whether each objective has been marked for a few
            % generations
            Mark = false(recordSize,Problem.M);
            % R2 ranking procedure
            [Rank,Norm] = R2Ranking(Population.objs,W,zmin,zmax);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                MatingPool  = TournamentSelection(2,Problem.N,Rank,Norm);
                Offspring   = OperatorGA(Population(MatingPool));
                Population  = [Population,Offspring];
                [Rank,Norm] = R2Ranking(Population.objs,W,zmin,zmax);
                [~,rank]    = sortrows([Rank,Norm]);
                Population  = Population(rank(1:Problem.N));
                Rank        = Rank(rank(1:Problem.N));
                Norm        = Norm(rank(1:Problem.N));
                [zmin,zmax,Record,Mark] = UpdateReferencePoints(Population.objs,zmin,zmax,Record,Mark,alpha,epsilon);
                
                %% HH: update all Populations
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, Offspring);
            end
        end
        
        function Population = update(~, Population, Problem, Offspring)
            %% Parameter setting
            recordSize = 5;

            %% Generate random population
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            % Ideal and nadir points
            zmin = min(Population.objs,[],1);
            zmax = max(Population.objs,[],1);
            % For storing the nadir vectors of a few generations
            Record = repmat(zmax,recordSize,1);
            % For storing whether each objective has been marked for a few
            % generations
            Mark = false(recordSize,Problem.M);

            Population  = [Population,Offspring];
            [Rank,Norm] = R2Ranking(Population.objs,W,zmin,zmax);
            [~,rank]    = sortrows([Rank,Norm]);
            Population  = Population(rank(1:Problem.N));
        end
    end
end