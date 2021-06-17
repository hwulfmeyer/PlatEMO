classdef HHProblem < PROBLEM
% <single> <real> 
% subProbMaxFE	--- 10000 --- maxFE for the underlying Problem
% subProbN      --- 100 --- population number of the underlying Problem
% subProblem	--- @DTLZ2 --- Pointer to the underlying Problem
%------------------------------- Copyright --------------------------------
% Copyright (C) 2021 Hans-Martin Wulfmeyer
%
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------
% platemo('algorithm',@GA,'problem',{@HHProblem,10000,100,@DTLZ2},'D',4,'N',4,'maxFE',20, 'save',0);
% subProbMaxFE should be at least subProbMaxFE/subProbN should be
% divideable by D
    properties(Access = private)
        subProbMaxFE; % maxFE for the underlying Problem
        subProbN; % population number of the underlying Problem
        subProblem; % Pointer to the underlying Problem
        encLength; %  Num of algorithms per HH run
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            [obj.subProbMaxFE, obj.subProbN, obj.subProblem] = obj.ParameterSet(10000, 100, @DTLZ2);
            obj.M = 1;
            if isempty(obj.D); obj.D = 10; end % number of algorithms per run
            obj.lower    = ones(1,obj.D)*1;
            obj.upper    = ones(1,obj.D)*3;
            obj.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            curProblem = PROBLEM.Current();
            sPRO = obj.subProblem('N', obj.subProbN, 'maxFE', obj.subProbMaxFE);
            sALG = @HHAlgorithm;
            PopObj = zeros(obj.N,obj.M);
            parfor (i = 1 : obj.N)
                algo = sALG('parameter', {uint8(PopDec(i,:))}, 'save', 1);
                algo.Solve(sPRO);
                res = -HV(algo.result{end}, sPRO.optimum);
                PopObj(i) = res;
            end
            PROBLEM.Current(curProblem);
        end
    end
end