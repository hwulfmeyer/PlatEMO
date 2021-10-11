classdef HHProblem < PROBLEM
% <single> <real>
% subProblem	--- @DTLZ2 --- Pointer to the underlying Problem
% subProbN      --- 100 --- population number of the underlying Problem
% subProbMaxFE	--- 10000 --- maxFE for the underlying Problem
% subProbD	--- 0 --- maxFE for the underlying Problem
% algorithmRuns	--- 7 --- number of runs per individual


%------------------------------- Copyright --------------------------------
% Copyright (C) 2021 Hans-Martin Wulfmeyer
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------
% e.g.:
% platemo('algorithm',@GA,'problem',{@HHProblem, @DTLZ2, 100, 10000},'D',6,'N',4,'maxFE',100, 'save',0);
% GA - Algorithm
%  - HHProblem(subProblem=@DTLZ2, subProbN=100, subProbMaxFE=10000)
%  - D=6, N=4, maxFE=100
%  - D=>encoding length, N=>number of individuals, maxFE=>max Generations
%  - subProblem(N=subProbN, maxFE=subProbMaxFE)

    properties(Access = private)
        subProblem; % Pointer to the underlying Problem
        subProbN; % population number of the underlying Problem
        subProbMaxFE; % maxFE for the underlying Problem
        subProbD; % D for the underlying Problem
        algorithmRuns; % number of runs per individual
        hhAlgorithm = @HHAlgorithm;
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.subProblem, obj.subProbN, obj.subProbMaxFE, obj.subProbD, obj.algorithmRuns] = obj.ParameterSet(@DTLZ2, 100, 10000, 0, 7);
            obj.M = 1;
            if isempty(obj.D); obj.D = 10; end % number of algorithms per run
            obj.lower    = 1;
            obj.upper    = length(obj.hhAlgorithm().moeas);
            obj.encoding = 'integer';
        end
        
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            curProblem = PROBLEM.Current();
            sPRO = obj.subProblem;
            sProN = obj.subProbN;
            sProFE = obj.subProbMaxFE;
            sD = obj.subProbD;
            sALG = obj.hhAlgorithm;
            PopObj = zeros(obj.N,obj.M);
            subProblems = cell(1,obj.algorithmRuns);
            for k = 1 : length(subProblems)
                if sD == 0
                    subProblems{k} = sPRO('N', sProN, 'maxFE', sProFE);
                else
                    subProblems{k} = sPRO('N', sProN, 'maxFE', sProFE, 'D', sD);
                end
            end
            for i = 1 : obj.N % => 10
                runs = zeros(length(subProblems),1);
                for k = 1 : length(subProblems) % => 3
                    algo = sALG('parameter', {PopDec(i,:), 1}, 'save', -1);
                    pro = subProblems{k};
                    algo.Solve(pro);
                    res = -HV(algo.hhresult, pro.optimum);
                    if res == 0
                        RefPoint = zeros(1, pro.M);
                        res = GD(algo.hhresult, RefPoint);
                    end
                    runs(k) = res;
                end
                PopObj(i) = median(runs);
            end
            PROBLEM.Current(curProblem);
        end
    end
end