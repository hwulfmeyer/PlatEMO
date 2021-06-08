classdef HHProblem < PROBLEM
% <single> <real> 
% Hans-Martin Wulfmeyer
% Otto-von-Guericke University Magdeburg
% - 2021
%--------------------------------------------------------------------------

    methods
        %% Default settings of the problem
        function Setting(obj)
            obj.M = 1;
            obj.D = 3;
            obj.lower    = zeros(1,obj.D)-3;
            obj.upper    = zeros(1,obj.D)+3;
            obj.encoding = 'real';
        end
        %% Calculate objective values
        function PopObj = CalObj(obj,PopDec)
            PopObj = -sum(PopDec.^4,2);
        end
    end
end