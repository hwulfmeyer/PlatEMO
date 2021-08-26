problems = {{@DTLZ1,5}, {@WFG1, 12}};   %,{@WFG1, 12},{@WFG1, 12} {@DTLZ2, 40}, {@DTLZ3, 5}, {@WFG1, 12}, {@WFG2, 12}, {@WFG3, 50}, {@WFG4, 50}};
expRepitions = 5;
hhRepitions = 11;

experimentconfigurations = cell(1,size(problems,2)*expRepitions);

for probi = 1 : size(problems,2)
    prob = problems{probi}{1};
    probD = problems{probi}{2};
    probstr = func2str(prob);

    for i = 1 : expRepitions
        filename = "Algorithms\HH_Evaluation\Data\results_exp1_" + probstr + "_" + i + "_.mat";
        if ~isfile(filename)
            experimentconfigurations{1, i + (probi-1)*expRepitions} = {prob, probD, i, filename};
        end
    end
end

parfor k = 1 : size(experimentconfigurations,2)
    prob = experimentconfigurations{1,k}{1};
    probD = experimentconfigurations{1,k}{2};
    i_exp = experimentconfigurations{1,k}{3};
    filename = experimentconfigurations{1,k}{4};
    timerVal = tic;
    [Dec,Obj] = platemo('algorithm',@GA,'problem',{@HHProblem,prob,20,2000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',10);
    timeToFinish = toc(timerVal);
    parsave(filename, Dec, Obj, timeToFinish);
end

function parsave(fname,a,b,c)
  save(fname, 'a', 'b', 'c','-mat')
end




