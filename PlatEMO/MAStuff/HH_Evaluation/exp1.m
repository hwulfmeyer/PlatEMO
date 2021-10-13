problems = {{@DTLZ1,5},{@WFG1, 12}};   %{@DTLZ2, 40}, {@DTLZ3, 5}, {@WFG1, 12}, {@WFG2, 12}, {@WFG3, 50}, {@WFG4, 50}};
expRepitions = 3;
hhRepitions = 1;
experimentconfigurations = cell(1,size(problems,2)*expRepitions);
warning('off')
for probi = 1 : size(problems,2)
    prob = problems{probi}{1};
    probD = problems{probi}{2};
    probstr = func2str(prob);

    for i = 1 : expRepitions
        filename = "Algorithms\HH_Evaluation\Data\results_exp1_" + probstr + "_" + i + "_.mat";
        experimentconfigurations{1, i + (probi-1)*expRepitions} = {prob, probD, i, filename};
    end
end

for k = 1 : size(experimentconfigurations,2)
    subProb = experimentconfigurations{1,k}{1};
    probD = experimentconfigurations{1,k}{2};
    i_exp = experimentconfigurations{1,k}{3};
    filename = experimentconfigurations{1,k}{4};
    if isfile(filename)
        %skip experiment
        continue
    end
    disp('BEGIN');
    disp(filename);
    %[Dec,Obj] = platemo('algorithm',@GA,'problem',{@HHProblem,prob,20,2000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',10);
	[Dec,Obj] = platemo('algorithm',@GA,'problem',{@HHProblem,prob,20,2000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',5,'runNo',i_exp,'extraStr',func2str(subProb));
    
	%algoGA = GA('D',2,'N',2,'maxFE',4,'save',2,'runNo',i_exp,'extraStr',func2str(subProb));
    %problemHH = HHProblem(subProb,20,40,probD,hhRepitions);
    %algoGA.Solve(problemHH);
    
    disp("END");

    %f = parfeval(@parallelRun,3,prob,probD);
    %parsave(filename, Dec, Obj, timeToFinish);
end

function parsave(fname,a,b,c)
  save(fname, 'a', 'b', 'c','-mat')
end


function [Dec,Obj,timeToFinish] = parallelRun(subProb,probD)

    timerVal = tic;
    
    algoGA = GA('D',10,'N',10,'maxFE',10,'save',10);
    problemHH = HHProblem(subProb,20,200,probD,hhRepitions);
    algoGA.Solve(problemHH);
    P = algoGA.result{end};
    Dec = P.decs;
    Obj = P.objs;

    timeToFinish = toc(timerVal);
end

%result{length(result),2}.objs




