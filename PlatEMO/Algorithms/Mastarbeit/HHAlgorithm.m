classdef HHAlgorithm < ALGORITHM
% <multi> <integer>
% MOEA Hyper-Heuristic
% encoding  --- [1,1,1,1] --- defines which algorithm to apply based on index of the MOEA in 'moeas'
            

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
        moeas = {HH_NSGAIII, HH_NSGAII, HH_GLMO, HH_MOEADD}; %available MOEAs 
    end
    properties
        moeas_pops;
        hhresult;
    end
    methods
        function main(Algorithm,Problem)
            %% Generate random population
            encoding = Algorithm.ParameterSet([1,1,1,1]);
            Population = Problem.Initialization();
            
            Algorithm.moeas_pops = cell(1,length(Algorithm.moeas));
            for k = 1 : length(Algorithm.moeas_pops)
                Algorithm.moeas_pops{k} = Population;
            end
            
            %%max Function evaluations per Algorithm run
            maxFEperAlgo = Algorithm.pro.maxFE/(length(encoding));
            for i = 1 : length(encoding)
                moea_index = encoding(i);
                Algorithm.moeas{moea_index}.main(Algorithm, Problem, maxFEperAlgo*i, moea_index);
                if Algorithm.pro.FE >= Algorithm.pro.maxFE
                    Algorithm.hhresult = Algorithm.moeas_pops{moea_index};
                    return
                end
            end
        end
        
        function update_populations(Algorithm, Problem, i, Offspring)
           for k = 1 : length(Algorithm.moeas)
                if i == k
                    continue
                end
                Algorithm.moeas{k}.update(Algorithm, Problem, k, Offspring);
           end
        end
    end
end