problems = {{@DTLZ1,5}};   %,{@WFG1, 12},{@WFG1, 12} {@DTLZ2, 40}, {@DTLZ3, 5}, {@WFG1, 12}, {@WFG2, 12}, {@WFG3, 50}, {@WFG4, 50}};
expRepitions = 1;
hhRepitions = 11;
warning('off', 'all')
for probi = 1 : size(problems,2)
    decRes = cell(1,expRepitions);
    objRes = cell(1,expRepitions);
    
    prob = problems{probi}{1};
    probD = problems{probi}{2};
    probstr = func2str(prob);
    disp(probstr);
    
    timerVal = tic;
    for i = 1 : expRepitions
        [Dec,Obj] = platemo('algorithm',@GA,'problem',{@HHProblem,prob,20,2000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',1);
        objRes{1,i} = Obj;
        decRes{1,i} = Dec;
    end
    timeToFinish = toc(timerVal);

    save("Algorithms\HH_Evaluation\Data\results_exp1_" + probstr + "_.mat", 'decRes', 'objRes', 'timeToFinish', '-mat');
end