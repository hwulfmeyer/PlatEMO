poolobj = gcp('nocreate');
delete(poolobj);

n = feature('numcores');
thePool = parpool(n);
cd(fileparts(mfilename('fullpath')));
addpath(genpath(cd));

packageList = createWorkpackages();
numPackages = size(packageList,2);

disp("Start")
disp(strcat("Num Packages ", num2str(numPackages)));
tStart = tic;

packagesInQueue = 0;

for i = 1:numPackages
    pack = packageList{1,i};
    subProb = pack{1};
    i_exp = pack{3};
    Algorithm = GA;
    folder = fullfile('Data',class(Algorithm));
    file  = fullfile(folder,sprintf('%s_%s_%s_R%d',class(Algorithm),class(HHProblem),func2str(subProb),i_exp));
    file = [file,'.mat'];
    if isfile(file)
        runFile = load(file);
        % number of saved populations should be 10
        % otherwise it did not finish
        if length(runFile.result) == 10
            disp(strcat("SKIP experiment: ", file));
            continue
        end
    end
    disp(strcat("MAKE experiment: ", file));
    f(packagesInQueue+1) = parfeval(thePool, @executeWorkpackage, 1, pack);
    packagesInQueue = packagesInQueue + 1;
end

disp("Packages in Queue: " + num2str(packagesInQueue));

for i = 1:packagesInQueue
    % fetchNext blocks until next results are available.
    disp(strcat("Queued Tasks: ", num2str(length(thePool.FevalQueue.QueuedFutures))));
    for i = 1:length(f)
        if strcmp(f(i).State, 'running')
            disp(strcat(func2str(f(i).InputArguments{1}{1}), " => ", datestr(f(i).StartDateTime )));
        end
    end
    [completedIdx,value] = fetchNext(f);
    disp(strcat("For i = ", num2str(i), " : ", value));
end

toc(tStart)
disp("Ende")

function packageList = createWorkpackages()
    problems = {{@DTLZ1,5}, {@DTLZ2, 40}, {@DTLZ3, 5},{@WFG3, 50}, {@WFG4, 50}, {@WFG5, 12}, {@WFG6, 12},{@ZDT1,30},{@ZDT2,30}}; %
    expRepitions = 21;
    
    packageList = cell(1,size(problems,2)*expRepitions);
    for probi = 1 : size(problems,2)
        prob = problems{probi}{1};
        probD = problems{probi}{2};
        for i = 1 : expRepitions
            packageList{1, i + (probi-1)*expRepitions} = {prob, probD, i};
        end
    end
end

function returnValue = executeWorkpackage(package)

    %% RULES
    % Rule #1: Diese Funktion erzeugt keine Ausgaben in die Konsole. Alle
    % Textausgaben sollten als String am Ende im returnValue zurückgegeben
    % werden.
    %
    % RULE #2: Diese Funktion ist unabhängig von weiteren Aufrufen der
    % Funktion. D.h. die Funktion basiert nicht dadrauf dass vorherige
    % Aufrufe bestimmte Dinge oder Inputargumente berechnet oder auf
    % die Platte geschrieben haben
    %
    % RULE #3: Diese Funktion greift auf gemeinsam genutze Dateien nur
    % lesend zu.
    %
    % RULE #4: Diese Funktion schreibt nur in Dateien, die von keinem
    % weiteren Aufruf der Funktion geschrieben werden. Das heißt pro
    % Funktionsaufruf eine eindeutige Logfile / Ergebnisfile / etc.
    %
    subProb = package{1};
    probD = package{2};
    i_exp = package{3};
    hhRepitions = 3;
    %platemo('algorithm',@GA,'problem',{@HHProblem,subProb,40,4000,probD,hhRepitions},'D',10,'N',100,'maxFE',5000,'save',10,'runNo',i_exp,'extraStr',func2str(subProb));
    platemo('algorithm',@GA,'problem',{@HHProblem,subProb,20,60,probD,hhRepitions},'D',2,'N',10,'maxFE',6,'save',3,'runNo',i_exp,'extraStr',func2str(subProb) + "_D4");
    
    returnValue = strcat("Successfully ran ", func2str(subProb), " with runNo ", num2str(i_exp));

end