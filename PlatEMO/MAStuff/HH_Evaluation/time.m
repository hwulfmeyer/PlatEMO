folderpath = "D:\git-repos\PlatEMO\PlatEMO\Data\GA\";
problems = {{@WFG1, 40}, {@WFG2, 50}, {@WFG5, 50},{@WFG6, 50}};
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
    fprintf('Avg: %f h\n', mean(timeRes));
    fprintf('Median: %f h\n\n', median(timeRes));
end