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
            
            algos = {@NSGAII, @MOEAD, @NSGAII, @MOEAD , @NSGAII, @MOEAD, @NSGAII, @MOEAD, @NSGAII, @MOEAD , @NSGAII, @MOEAD};
            args = {Algorithm, Population, Problem};
            maxFEperAlgo = Algorithm.pro.maxFE/length(algos);
            while Algorithm.NotTerminated(Population)
                for i = 1 : length(algos)
                    Population = algos{i}(args{:}, maxFEperAlgo*i);
                    args = {Algorithm, Population, Problem};
                end
            end
        end
        
        function Population = NSGAII(Algorithm, Population, Problem, maxFE)
            disp('NSGAII')
            disp(maxFE)
            %% Generate random population
            [~,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection(Population,Problem.N);
            
            %% Optimization
            while Algorithm.pro.FE < maxFE && Algorithm.NotTerminated(Population)
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);
            end
        end
        
        function Population = MOEAD(Algorithm, Population, Problem, maxFE)
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

            %% Generate random population
            Z = min(Population.objs,[],1);

            %% Optimization
            while Algorithm.pro.FE < maxFE && Algorithm.NotTerminated(Population)
                % For each solution
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
            end
        end
    end
end