folderpath = "D:\git-repos\PlatEMO\PlatEMO\MAStuff\HH_Evaluation\Data_Reduced\Data\GA\";
problems = {{@DTLZ1,1},{@DTLZ2,1},{@DTLZ3,1},{@WFG3,1},{@WFG4,1},{@WFG5,1},{@WFG6,1},{@ZDT1,1},{@ZDT2,1}};
for probi = 1 : size(problems,2)
    probstr = func2str(problems{probi}{1});
    fstruct = dir(folderpath + "GA_HHProblem_" + probstr + "_R*.mat");
    expRepitions = length(fstruct);
    for i = 1 : expRepitions
        data = load(folderpath + fstruct(i).name);
        runtime =  data.metric.runtime;
        result = data.result;
         
        objRes = cell(length(result{length(result),2}),length(result));
        objDec = cell(length(result{length(result),2}),length(result));
        %result{length(result),2}.dec
        for idx = 1:length(result)
            for idy = 1:length(result{idx,2})
                objDec{idy,idx} = result{idx,2}(idy).dec;
                objRes{idy,idx} = result{idx,2}(idy).obj;
            end
        end
        
        objRes = cell2mat(objRes);
        objDec = cell2mat(objDec);
        save(folderpath + 'converted\' + probstr + '_R'+i+'.mat', 'objRes', 'objDec','runtime', '-v7');
    end
end