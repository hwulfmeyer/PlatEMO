classdef HHProblem < PROBLEM
% <single> <real>
% subProblem	--- @DTLZ2 --- Pointer to the underlying Problem
% subProbN      --- 100 --- population number of the underlying Problem
% subProbMaxFE	--- 10000 --- maxFE for the underlying Problem
% algorithmRuns	--- 3 --- number of runs per individual


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
        algorithmRuns; % number of runs per individual
        hhAlgorithm = @HHAlgorithm;
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.subProblem, obj.subProbN, obj.subProbMaxFE, obj.algorithmRuns] = obj.ParameterSet(@DTLZ2, 100, 10000, 3);
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
            sALG = obj.hhAlgorithm;
            PopObj = zeros(obj.N,obj.M);
            parfor i = 1 : obj.N
                results = zeros(obj.algorithmRuns,1);
                for k = 1 : length(results)
                    algo = sALG('parameter', {PopDec(i,:), 1}, 'save', -1);
                    pro = sPRO('N', sProN, 'maxFE', sProFE);
                    algo.Solve(pro);
                    res = -HV(algo.hhresult, pro.optimum);
                    results(k) = res;
                end
                PopObj(i) = median(results);
            end
            PROBLEM.Current(curProblem);
        end
    end
end