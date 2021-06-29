classdef HHProblem < PROBLEM
% <single> <real>
% subProblem	--- @DTLZ2 --- Pointer to the underlying Problem
% subProbN      --- 100 --- population number of the underlying Problem
% subProbMaxFE	--- 10000 --- maxFE for the underlying Problem


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
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.subProblem, obj.subProbN, obj.subProbMaxFE] = obj.ParameterSet(@DTLZ2, 100, 10000);
            obj.M = 1;
            if isempty(obj.D); obj.D = 4; end % number of algorithms per run
            obj.lower    = 1;
            obj.upper    = 3;
            obj.encoding = 'integer';
        end
        
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            curProblem = PROBLEM.Current();
            sPRO = obj.subProblem;
            sProN = obj.subProbN;
            sProFE = obj.subProbMaxFE;
            sALG = @HHAlgorithm;
            PopObj = zeros(obj.N,obj.M);
            parfor i = 1 : obj.N
                algo = sALG('parameter', {PopDec(i,:)}, 'save', -1);
                pro = sPRO('N', sProN, 'maxFE', sProFE);
                algo.Solve(pro);
                res = IGD(algo.result{end}, pro.optimum);
                PopObj(i) = res;
            end
            PROBLEM.Current(curProblem);
        end
    end
end