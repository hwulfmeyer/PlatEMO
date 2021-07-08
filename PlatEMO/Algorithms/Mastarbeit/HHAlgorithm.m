classdef HHAlgorithm < ALGORITHM
% <multi> <integer>
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
        moeas = {HH_NSGAIII, HH_NSGAII, HH_GLMO, HH_MOEAD, HH_MOEADD, HH_MOMBIII, HH_SPEA2, HH_SPEA2SDE}; %available MOEAs 
    end
    properties
        moeas_pops;
        hhresult;
    end
    methods
        function main(Algorithm,Problem)
            %% Generate random population
            [encoding, hhRun] = Algorithm.ParameterSet([1,1,1,1], 1);
            Population = Problem.Initialization();
            
            Algorithm.moeas_pops = cell(1,length(Algorithm.moeas));
            for k = 1 : length(Algorithm.moeas_pops)
                Algorithm.moeas_pops{k} = Population;
            end
            
            %%max Function evaluations per Algorithm run
            maxFEperAlgo = floor((Algorithm.pro.maxFE/Algorithm.pro.N)/length(encoding))*Algorithm.pro.N;
            for i = 1 : length(encoding)
                moea_index = encoding(i);
                maxFE = maxFEperAlgo*i;
                if i == length(encoding)
                    maxFE = Algorithm.pro.maxFE;
                end
                Algorithm.moeas{moea_index}.main(Algorithm, Problem, maxFE, moea_index);
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
           for k = 1 : length(Algorithm.moeas)
                if i == k
                    continue
                end
                Algorithm.moeas_pops{k} = Algorithm.moeas{k}.update(Algorithm.moeas_pops{k}, Problem, Offspring);
           end
        end
    end
end