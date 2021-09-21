n = feature('numcores');
%thePool = parpool(n);
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
        disp(strcat("skip experiment: ", file));
        continue
    end
    f(packagesInQueue+1) = parfeval(@executeWorkpackage, 1, pack);
    packagesInQueue = packagesInQueue + 1;
end

for i = 1:packagesInQueue
    % fetchNext blocks until next results are available.
    [completedIdx,value] = fetchNext(f);
    aString = strcat("For i = ", num2str(i), " : ", value);
    disp(aString);
end

toc(tStart)
disp("Ende")

function packageList = createWorkpackages()
    problems = {{@DTLZ1,5}};   %{{@DTLZ1,5}, {@DTLZ2, 40}, {@DTLZ3, 5}, {@WFG1, 12}, {@WFG2, 12}, {@WFG3, 50}, {@WFG4, 50}};
    expRepitions = 3;
    
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
    platemo('algorithm',@GA,'problem',{@HHProblem,subProb,40,4000,probD,hhRepitions},'D',10,'N',100,'maxFE',10000,'save',10,'runNo',i_exp,'extraStr',func2str(subProb));
    %platemo('algorithm',@GA,'problem',{@HHProblem,subProb,20,20,probD,hhRepitions},'D',2,'N',2,'maxFE',20,'save',10,'runNo',i_exp,'extraStr',func2str(subProb));
    
    returnValue = strcat("Successfully ran ", func2str(subProb), " with runNo ", num2str(i_exp));

end