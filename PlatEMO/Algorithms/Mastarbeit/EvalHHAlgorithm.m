classdef EvalHHAlgorithm < ALGORITHM
% <multi/many> <real/binary/permutation>
% Evaluation MOEA Hyper-Heuristic

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
    end
    methods
        function main(Algorithm,Problem)
            hhRun = 0;
            %% Generate random population
            probstr = class(Problem);
            data = load("Algorithms\HH_Evaluation\Data\results_exp1_" + probstr + "_.mat");
            expRepitions = size(data.objRes,2);
            decRes = cell(1,expRepitions);
            objRes = cell(1,expRepitions);
            for i = 1 : size(data.objRes,2)
                minval = min(data.objRes{i});
                minidx = find(data.objRes{i} == minval, 1, 'first');
                objRes{1,i} = data.objRes{i}(minidx);
                decRes{1,i} = data.decRes{i}(minidx,:);
            end 
            objRes = cell2mat(objRes);
            medval = median(objRes);
            medidx = find(objRes == medval, 1, 'first');
            encoding = decRes{medidx};

            %set Problem.N for all equal
            [~,Problem.N] = UniformPoint(Problem.N,Problem.M);
            Population = Problem.Initialization();
            
            Algorithm.moeas_pops = cell(1,length(Algorithm.moeas));
            for k = 1 : length(Algorithm.moeas_pops)
                Algorithm.moeas_pops{k} = Population;
            end
            %%max Function evaluations per Algorithm run
            maxFEperAlgo = floor((Algorithm.pro.maxFE/Problem.N)/length(encoding))*Problem.N;
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