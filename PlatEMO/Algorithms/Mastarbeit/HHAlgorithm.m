classdef HHAlgorithm < ALGORITHM
% <single> <real>
% Copyright (C) 2021 Hans-Martin Wulfmeyer

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 
% International License. (CC BY-NC-SA 4.0). To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc-sa/4.0/
%--------------------------------------------------------------------------

    methods
        function main(Algorithm,Problem)
            %% Generate random population
            Population = Problem.Initialization();
            
            Alg = NSGAII('maxFE', 1000);
            Alg.Solve(Problem);
            Population = Alg.result(end);
        end
    end
end