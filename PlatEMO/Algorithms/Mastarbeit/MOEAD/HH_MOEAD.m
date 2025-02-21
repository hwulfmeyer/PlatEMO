classdef HH_MOEAD
% <multi/many> <real/binary/permutation>
% Multiobjective evolutionary algorithm based on decomposition
% type --- 1 --- The type of aggregation function

%------------------------------- Reference --------------------------------
% Q. Zhang and H. Li, MOEA/D: A multiobjective evolutionary algorithm based
% on decomposition, IEEE Transactions on Evolutionary Computation, 2007,
% 11(6): 712-731.
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
            %type = Algorithm.ParameterSet(1);
            type = 1;
       
            %% Generate the weight vectors
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            T = ceil(Problem.N/10);

            %% Detect the neighbours of each solution
            B = pdist2(W,W);
            [~,B] = sort(B,2);
            B = B(:,1:T);

            %% get population
            Population = Algorithm.moeas_pops{k};
            Z = min(Population.objs,[],1);

            %% Optimization
            while Algorithm.pro.FE < maxFE
                % For each solution
                offspringsave = [];
                for i = 1 : Problem.N
                    % Choose the parents
                    P = B(i,randperm(size(B,2)));

                    % Generate an offspring
                    Offspring = OperatorGAhalf(Population(P(1:2)));
                    offspringsave = [offspringsave, Offspring];
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
                Algorithm.moeas_pops{k} = Population;
                Algorithm.update_populations(Problem, k, offspringsave);
            end
        end
        
        function Population = update(~, Population, Problem, Offsprings)
            type = 1;
            
            %% Generate the weight vectors
            [W,Problem.N] = UniformPoint(Problem.N,Problem.M);
            T = ceil(Problem.N/10);

            %% Detect the neighbours of each solution
            B = pdist2(W,W);
            [~,B] = sort(B,2);
            B = B(:,1:T);
            
            Z = min(Population.objs,[],1);
            
            for i = 1 : length(Offsprings)
                % Choose the parents
                % Generate an offspring
                Offspring = Offsprings(i);
                
                % j is the neighborhood
                [~,j] = max(1-pdist2(Offspring.objs,W,'cosine'),[],2);
                P = B(j, randperm(size(B,2)));
          
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
