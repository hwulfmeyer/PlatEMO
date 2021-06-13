classdef HHProblem < PROBLEM
% <single> <real> 
% Copyright (C) 2021 Hans-Martin Wulfmeyer

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------

    methods
        %% Default settings of the problem
        function Setting(obj)
            obj.M = 1;
            obj.D = 1;
            obj.lower    = ones(1,obj.D)*1;
            obj.upper    = ones(1,obj.D)*3;
            obj.encoding = 'real';          
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            % problem auslesen <= HHProblem
            tmp = PROBLEM.Current();
            subProblem = @DTLZ2;
            subProblem = subProblem();
            subAlgorithm = @MOPSO;
            subAlgorithm = subAlgorithm();
            
            subAlgorithm.Solve(subProblem);
            PopObj = zeros(obj.N);
            for i = 1 : obj.N
                res = HV(subAlgorithm.result{end}, subProblem.optimum);
                PopObj(i) = res;
            end
            disp(PopObj)
            PROBLEM.Current(tmp);
        end
    end
end