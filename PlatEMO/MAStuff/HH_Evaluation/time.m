folderpath = "D:\git-repos\PlatEMO\PlatEMO\MAStuff\HH_Evaluation\Data\Data\GA\";
problems = {{@DTLZ1,1},{@DTLZ2,1},{@DTLZ3,1},{@WFG3,1},{@WFG4,1},{@WFG5,1},{@WFG6,1},{@ZDT1,1},{@ZDT2,1}};
for probi = 1 : size(problems,2)
    probstr = func2str(problems{probi}{1});
    fstruct = dir(folderpath + "GA_HHProblem_" + probstr + "_R*.mat");
    expRepitions = length(fstruct);
    timeRes = cell(expRepitions,1);
    for i = 1 : expRepitions
        data = load(folderpath + fstruct(i).name);
        timeRes{i} = data.metric.runtime / 3600;
    end
    timeRes = cell2mat(timeRes);
    fprintf(probstr + "\n");
    fprintf('Reps: %i \n', expRepitions);
    fprintf('Avg: %f h\n', mean(timeRes));
    fprintf('Median: %f h\n', median(timeRes));
    fprintf('Max: %f h\n', max(timeRes));
    fprintf('Min: %f h\n\n', min(timeRes));
end