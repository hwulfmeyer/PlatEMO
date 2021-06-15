classdef HHAlgorithm < ALGORITHM
% <multi> <real/binary/permutation>
% MOEA Hyper-Heuristic
% enc --- [1,1,1,1] --- defines which algorithm to apply based on index of the MOEA in 'moeas'
            

%------------------------------- Copyright --------------------------------
% Copyright (C) 2021 Hans-Martin Wulfmeyer
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Generate random population
            encoding = Algorithm.ParameterSet(ones(1,10));
            Population = Problem.Initialization();
            
            %%available MOEAs
            moeas = {@NSGAII, @NSGAIII, @MOEAD};
            moeas_pops = cell(1,length(moeas));
            for k = 1 : length(moeas_pops)
                moeas_pops{k} = Population;
            end
            
            %%max Function evaluations per Algorithm run
            maxFEperAlgo = Algorithm.pro.maxFE/(length(encoding));
            
            for i = 1 : length(encoding)
                moea_index = encoding(i);
                moeas_pops = moeas{moea_index}(Algorithm, moeas_pops, Problem, maxFEperAlgo*i, moea_index, NaN, moeas);
            end
        end
        
        function Moeas_pops = NSGAII(Algorithm, Moeas_pops, Problem, maxFE, i, NewPopulation, Moeas)
            if maxFE > 0
                disp(Moeas{i})
                disp(maxFE)
            end
            
            Population = Moeas_pops{i};
            [Population, FrontNo, CrowdDis] = NSGAIIEnvironmentalSelection(Population,Problem.N);
            
            %% HH: apply EnvironmentalSelection and Update
            if maxFE == 0
                [Population,~,~] = NSGAIIEnvironmentalSelection([Population,NewPopulation],Problem.N);
                Moeas_pops{i} = Population;
                return
            end
            
            %% Optimization
            while Algorithm.NotTerminated(Population) && Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,FrontNo,-CrowdDis);
                Offspring  = OperatorGA(Population(MatingPool));
                [Population,FrontNo,CrowdDis] = NSGAIIEnvironmentalSelection([Population,Offspring],Problem.N);
                
                %% HH: update all Populations
                for k = 1 : length(Moeas_pops)
                    if i == k
                        Moeas_pops{k} = Population;
                        continue
                    end
                    Moeas_pops = Moeas{k}(Algorithm, Moeas_pops, Problem, 0, k, Offspring, Moeas);
                end
            end
        end
        
        
        function Moeas_pops = NSGAIII(Algorithm, Moeas_pops, Problem, maxFE, i, NewPopulation, Moeas)
            if maxFE > 0
                disp(Moeas{i})
                disp(maxFE)
            end
            
            %% Generate the reference points and random population
            [Z,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population = Moeas_pops{i};
            Zmin          = min(Population(all(Population.cons<=0,2)).objs,[],1);
            
            %% HH: apply EnvironmentalSelection and Update
            if maxFE == 0
                Population = NSGAIIIEnvironmentalSelection([Population,NewPopulation],Problem.N,Z,Zmin);
                Moeas_pops{i} = Population;
                return
            end
            
            %% Optimization
            while Algorithm.NotTerminated(Population) && Algorithm.pro.FE < maxFE
                MatingPool = TournamentSelection(2,Problem.N,sum(max(0,Population.cons),2));
                Offspring  = OperatorGA(Population(MatingPool));
                Zmin       = min([Zmin;Offspring(all(Offspring.cons<=0,2)).objs],[],1);
                Population = NSGAIIIEnvironmentalSelection([Population,Offspring],Problem.N,Z,Zmin);
                
                %% HH: update all Populations
                for k = 1 : length(Moeas_pops)
                    if i == k
                        Moeas_pops{k} = Population;
                        continue
                    end
                    Moeas_pops = Moeas{k}(Algorithm, Moeas_pops, Problem, 0, k, Offspring, Moeas);
                end
            end
        end
        
        function Moeas_pops = MOEAD(Algorithm, Moeas_pops, Problem, maxFE, i, NewPopulation, Moeas)
            if maxFE > 0
                disp(Moeas{i})
                disp(maxFE)
            end
            
            %% Parameter setting
            type = 1;

            %% Generate the weight vectors
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            T = ceil(Problem.N/10);

            %% Detect the neighbours of each solution
            B = pdist2(W,W);
            [~,B] = sort(B,2);
            B = B(:,1:T);
            
            Population = Moeas_pops{i};
            Z = min(Population.objs,[],1);

            %% HH: apply EnvironmentalSelection and Update
            if maxFE == 0
                %% apply scalarization
                Moeas_pops{i} = NewPopulation;
                return
            end
            
            %% Optimization
            while Algorithm.NotTerminated(Population) && Algorithm.pro.FE < maxFE
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
                
                %% HH: update all Populations
                for k = 1 : length(Moeas_pops)
                    if i == k
                        Moeas_pops{k} = Population;
                        continue
                    end
                    Moeas_pops = Moeas{k}(Algorithm, Moeas_pops, Problem, 0, k, Population, Moeas);
                end
            end
        end
    end
end