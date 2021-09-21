classdef HHAlgorithm < ALGORITHM
% <multi/many> <real/binary/permutation>
% MOEA Hyper-Heuristic
% encoding  --- [1,1,1,1] --- defines which algorithm to apply based on index of the MOEA in 'moeas'
% hhRun --- 1 --- if the algorithm is run inside the HHProblem (1) or not (0)

%------------------------------- Copyright --------------------------------
% Copyright (C) 2021 Hans-Martin Wulfmeyer
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------
% platemo('algorithm',{@HHAlgorithm, [1,1,1,1]},'problem',@DTLZ2,'N',100,'maxFE',10000,'save',0);
%
    properties(Constant)
        % #1 HH_GLMO, #2 HH_IBEA, #3 HH_MOEAD, #4 HH_MOEADD, #5 HH_MOMBIII,
        % #6 HH_NSGAII, #7 HH_NSGAIII, #8 HH_SPEA2, #9 HH_SPEA2SDE, #10 HH_tDEA
        moeas = {HH_GLMO, HH_IBEA, HH_MOEAD, HH_MOEADD, HH_MOMBIII, HH_NSGAII, HH_NSGAIII, HH_SPEA2, HH_SPEA2SDE, HH_tDEA}; %available MOEAs 
    end
    properties
        moeas_pops;
        hhresult;
        encoding;
        algorithmsUsed;    
    end
    methods
        function main(Algorithm,Problem)
            %% Generate random population
            [Algorithm.encoding, hhRun] = Algorithm.ParameterSet([1,1,1,1], 1);
            Algorithm.algorithmsUsed = unique(Algorithm.encoding);
            
            %set Problem.N for all equal
            [~,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Algorithm.moeas_pops = cell(1,length(Algorithm.moeas));
            for k = 1 : length(Algorithm.algorithmsUsed)
                moea_index = Algorithm.algorithmsUsed(k);
                Algorithm.moeas_pops{moea_index} = Problem.Initialization();
            end
            %%max Function evaluations per Algorithm run
            maxFEperAlgo = floor((Algorithm.pro.maxFE/Problem.N)/length(Algorithm.encoding))*Problem.N;
            
            for i = 1 : length(Algorithm.encoding)
                moea_index = Algorithm.encoding(i);
                maxFE = maxFEperAlgo*i;
                if i == length(Algorithm.encoding)
                    maxFE = Algorithm.pro.maxFE;
                end
                Algorithm.moeas{moea_index}.main(Algorithm, Problem, maxFE, moea_index);
                %Population = Algorithm.moeas_pops{moea_index};
                %Algorithm.update_populations2(Problem, moea_index, Population);
                if hhRun == 1
                    if Algorithm.pro.FE >= Algorithm.pro.maxFE
                        Algorithm.hhresult = Algorithm.moeas_pops{moea_index};
                        return
                    end
                else
                    if ~Algorithm.NotTerminated(Algorithm.moeas_pops{moea_index})
                        return
                    end
                end
            end
        end
        
        function update_populations(Algorithm, Problem, i, Offspring)       
           for k = 1 : length(Algorithm.algorithmsUsed)
               updateAlgo = Algorithm.algorithmsUsed(k);
                if i == updateAlgo
                    continue
                end
                Algorithm.moeas_pops{updateAlgo} = Algorithm.moeas{updateAlgo}.update(Algorithm.moeas_pops{updateAlgo}, Problem, Offspring);
           end
        end
        
        function update_populations2(Algorithm, Problem, i, Offspring)
           %for updating once after ever algorithm, currently not used
           for k = 1 : length(Algorithm.algorithmsUsed)
               updateAlgo = Algorithm.algorithmsUsed(k);
                if i == updateAlgo
                    continue
                end
                Algorithm.moeas_pops{updateAlgo} = Algorithm.moeas{updateAlgo}.update(Algorithm.moeas_pops{updateAlgo}, Problem, Offspring);
           end
        end
    end
end