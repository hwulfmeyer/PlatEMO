problems = {{@DTLZ2,40},{@DTLZ1, 5}};   %, {@DTLZ3, 5}, {@WFG1, 12}, {@WFG1, 12}, {@WFG2, 12}, {@WFG3, 50}, {@WFG4, 50}};
expRepitions = 5;
hhRepitions = 5;
for probi = 1 : size(problems,2)
    decRes = cell(1,expRepitions);
    objRes = cell(1,expRepitions);
    prob = problems{probi}{1};
    probD = problems{probi}{2};
    probstr = func2str(prob);
    disp(probstr);
    timerVal = tic;
    parfor i = 1 : expRepitions
        disp("##### Beginning Rep");
        disp(i);
        [Dec,Obj] = platemo('algorithm',@GA,'problem',{@HHProblem,prob,20,2000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',1);
        minval = min(Obj);
        minidx = find(Obj == minval, 1, 'first');
        decRes{1,i} = Dec(minidx,:);
        objRes{1,i} = Obj(minidx);
        disp(i);
        disp("##### Finishing Rep");
    end
    timeToFinish = toc(timerVal);
    objectives = cell2mat(objRes);
    medval = median(objectives);
    save("Algorithms\HH_Evaluation\Data\results_exp1_" + probstr + "_.mat", 'decRes', 'objRes', 'timeToFinish', '-mat');
end