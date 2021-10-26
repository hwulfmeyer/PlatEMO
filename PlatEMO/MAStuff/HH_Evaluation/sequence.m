folderpath = "MAStuff\HH_Evaluation\Data\12.10.2021\GA\";
problems = {{@DTLZ1, 40},{@DTLZ3, 50}};
for probi = 1 : size(problems,2)
    probstr = func2str(problems{probi}{1});
    fstruct = dir(folderpath + "GA_HHProblem_" + probstr + "_R*.mat");
    expRepitions = length(fstruct);
    decRes = cell(expRepitions,1);
    objRes = cell(expRepitions,1);
    for i = 1 : expRepitions
        data = load(folderpath + fstruct(i).name);
        result = data.result;
        minObj = realmax;
        minIdx = 0;
        for idx = 1:length(result{length(result),2})
            solution = result{length(result),2}(idx);
            if solution.obj < minObj
                minObj = solution.obj;
                minIdx = idx;
            end
        end
        if minIdx ~= 1
            disp(minIdx)
        end
        decRes{i} = result{length(result),2}(minIdx).dec;
        objRes{i} = result{length(result),2}(minIdx).obj;
    end
    objRes = cell2mat(objRes);
    medval = median(objRes);
    medidx = find(objRes == medval, 1, 'first');
    decRes
    objRes
    medval
    medidx
    meddec = decRes{medidx}
end