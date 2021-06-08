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