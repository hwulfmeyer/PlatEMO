classdef FixedHHAlgorithm < ALGORITHM
% <multi> <real/binary/permutation>
% Copyright (C) 2021 Hans-Martin Wulfmeyer

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Population = Problem.Initialization();
            
            algos = {@NSGAII, @MOEAD};
            repitions = 6;
            algopops = {Population, Population};
            args = {Algorithm, algopops, Problem};
            maxFEperAlgo = Algorithm.pro.maxFE/(length(algos)*repitions);
            while Algorithm.NotTerminated(Population)
                for k = 1 : repitions
                    for i = 1 : length(algos)
                        Population = algos{i}(args{:}, maxFEperAlgo*((k-1)*length(algos)+i), i);
                        args = {Algorithm, Population, Problem};
                    end
                end
            end
        end
        
        function Algopops = NSGAII(Algorithm, Algopops, Problem, maxFE, i)
            disp('NSGAII')
            disp(maxFE)
            Population = Algopops{i};
            [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection(Population,Problem.N);
            %% Optimization
            while Algorithm.NotTerminated(Population) && Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);
                %%update all Populations
                for k = 1 : length(Algopops)
                    Algopops{k} = Population;
                end
            end
        end
        
        function Algopops = MOEAD(Algorithm, Algopops, Problem, maxFE, i)
            disp('MOEAD')
            disp(maxFE)
            %% Parameter setting
            type = 1;

            %% Generate the weight vectors
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            T = ceil(Problem.N/10);

            %% Detect the neighbours of each solution
            B = pdist2(W,W);
            [~,B] = sort(B,2);
            B = B(:,1:T);
            
            Population = Algopops{i};
            Z = min(Population.objs,[],1);

            %% Optimization
            while Algorithm.NotTerminated(Population) && Algorithm.pro.FE < maxFE
                % For each solution
                PopulationOld = Population;
                for i = 1 : Problem.N
                    % Choose the parents
                    P = B(i,randperm(size(B,2)));

                    % Generate an offspring
                    Offspring = OperatorGAhalf(Population(P(1:2)));

                    % Update the ideal point
                    Z = min(Z,Offspring.obj);

                    % Update the neighbours
                    switch type
                        case 1
                            % PBI approach
                            normW   = sqrt(sum(W(P,:).^2,2));
                            normP   = sqrt(sum((Population(P).objs-repmat(Z,T,1)).^2,2));
                            normO   = sqrt(sum((Offspring.obj-Z).^2,2));
                            CosineP = sum((Population(P).objs-repmat(Z,T,1)).*W(P,:),2)./normW./normP;
                            CosineO = sum(repmat(Offspring.obj-Z,T,1).*W(P,:),2)./normW./normO;
                            g_old   = normP.*CosineP + 5*normP.*sqrt(1-CosineP.^2);
                            g_new   = normO.*CosineO + 5*normO.*sqrt(1-CosineO.^2);
                        case 2
                            % Tchebycheff approach
                            g_old = max(abs(Population(P).objs-repmat(Z,T,1)).*W(P,:),[],2);
                            g_new = max(repmat(abs(Offspring.obj-Z),T,1).*W(P,:),[],2);
                        case 3
                            % Tchebycheff approach with normalization
                            Zmax  = max(Population.objs,[],1);
                            g_old = max(abs(Population(P).objs-repmat(Z,T,1))./repmat(Zmax-Z,T,1).*W(P,:),[],2);
                            g_new = max(repmat(abs(Offspring.obj-Z)./(Zmax-Z),T,1).*W(P,:),[],2);
                        case 4
                            % Modified Tchebycheff approach
                            g_old = max(abs(Population(P).objs-repmat(Z,T,1))./W(P,:),[],2);
                            g_new = max(repmat(abs(Offspring.obj-Z),T,1)./W(P,:),[],2);
                    end
                    Population(P(g_old>=g_new)) = Offspring;
                end
                %%update all Populations
                [PopulationNSGAII,~,~] = NSGAIIEnvironmentalSelection([PopulationOld,Population],Problem.N);
                for k = 1 : length(Algopops)
                    if i == k
                        Algopops{i} = Population
                        continue
                    end
                    Algopops{k} = PopulationNSGAII;
                end
            end
        end
    end
end