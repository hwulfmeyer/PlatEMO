classdef HHProblem < PROBLEM
% <single> <real> 
% subProbMaxFE --- 10000 --- maxFE for the underlying Problem
% subProbN --- 100 --- population number of the underlying Problem
% Copyright (C) 2021 Hans-Martin Wulfmeyer

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------
    properties(Access = private)
        subProbMaxFE = 10000;
        subProbN = 100;
    end
    methods
        %% Default settings of the problem
        function Setting(obj)
            obj.subProbMaxFE = obj.ParameterSet(9999); %does not work yet, is not properly set
            obj.subProbN = obj.ParameterSet(95);
            obj.M = 1;
            obj.D = 1;
            obj.lower    = ones(1,obj.D)*1;
            obj.upper    = ones(1,obj.D)*50;
            obj.encoding = 'real';          
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            tmp = PROBLEM.Current();
            subProblem = @DTLZ2;
            subProblem = subProblem('N', obj.subProbN, 'maxFE', obj.subProbMaxFE);
            disp(subProblem.N);
            disp(subProblem.maxFE);
            subAlgorithm = @MOPSO;     
            PopObj = zeros(obj.N,obj.M);
            for i = 1 : obj.N
                algo = subAlgorithm('parameter', {PopDec(i)}, 'save', 1);
                algo.Solve(subProblem);
                res = 1/HV(algo.result{end}, subProblem.optimum);
                PopObj(i) = res;
            end
            PROBLEM.Current(tmp);
        end
    end
end