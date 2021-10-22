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
        encoding;
        algorithmsUsed;   
    end
    methods
        function main(Algorithm,Problem)
            hhRun = 0;
            %% get encoding
            probstr = class(Problem);
            Algorithm.encoding = Algorithm.GetEncoding(probstr);
            Algorithm.algorithmsUsed = unique(Algorithm.encoding);
            
            %set Problem.N for all equal
            [~,Problem.N] = UniformPoint(Problem.N,Problem.M);
            disp(Problem.N);
            Algorithm.moeas_pops = cell(1,length(Algorithm.encoding));
            for k = 1 : length(Algorithm.encoding)
                Algorithm.moeas_pops{k} = Problem.Initialization();
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
        
        function meddec = GetEncoding(~, probstr)
            folderpath = "MAStuff\HH_Evaluation\Data\12.10.2021\GA\";
            fstruct = dir(folderpath + "GA_HHProblem_" + probstr + "_R*.mat");
            expRepitions = length(fstruct);
            decRes = cell(expRepitions,1);
            objRes = cell(expRepitions,1);
            for i = 1 : expRepitions
                data = load(folderpath + fstruct(i).name);
                result = data.result;
                minObj = realmax;
                minIdx = 0;
                for idx = 1:length(result{length(result),2})
                    solution = result{length(result),2}(idx);
                    if solution.obj < minObj
                        minObj = solution.obj;
                        minIdx = idx;
                    end
                end
                if minIdx ~= 1
                    disp(minIdx)
                end
                decRes{i} = result{length(result),2}(minIdx).dec;
                objRes{i} = result{length(result),2}(minIdx).obj;
            end
            objRes = cell2mat(objRes);
            medval = median(objRes);
            medidx = find(objRes == medval, 1, 'first');
            meddec = decRes{medidx};
        end
    end
end