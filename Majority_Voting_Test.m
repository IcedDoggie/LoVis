function accuracy = Majority_Voting_Test(filename, dataDir)

    featMethod = 'phow';
    %featMethod = 'dsift';
    %featMethod = 'sift';
    %featMethod = 'cat_phow_dsift';
    %featMethod = 'cat_phow_sift';
    %featMethod = 'cat_dsift_sift';
    %featMethod = 'cat_phow_dsift_sift';

    switch featMethod
        case {'phow'}
           result = strcat(filename,' - TackLabels_PHOW.dat');
        case {'dsift'}
           result = strcat(filename,' - TackLabels_DSIFT.dat');
        case {'sift'}
           result = strcat(filename,' - TackLabels_SIFT.dat'); 
        case {'cat_phow_dsift'}
           result = strcat(filename,' - TackLabels_CAT_PHOW_DSIFT.dat');     
        case {'cat_phow_sift'}
           result = strcat(filename,' - TackLabels_CAT_PHOW_SIFT.dat');    
        case {'cat_dsift_sift'}
           result = strcat(filename,' - TackLabels_CAT_DSIFT_SIFT.dat');    
        case {'cat_phow_dsift_sift'}
           result = strcat(filename,' - TackLabels_CAT_PHOW_DSIFT_SIFT.dat');    
    end


    proof = strcat(filename,' - GroundTruth.dat');
    %classes = {'Bicycle','Car','Clutter','GOP','Pedestrian'};
    classes = {'Bicycle','Cars','Clutter','GOP','Humans'}; 
    dataDir = dataDir; %'C:\Users\Matti\Downloads\camera017\Tracks';

    resultTable = readtable(fullfile(dataDir,result));
    proofTable = readtable(fullfile(dataDir,proof));

    resultCell = table2cell(resultTable);
    proofCell = table2cell(proofTable);

    for i=1:length(resultCell)
        if(strcmp(resultCell(i,2),classes(1)))
            resultCell(i,2) = {1};

        elseif(strcmp(resultCell(i,2),classes(2)))
            resultCell(i,2) = {2};

        elseif(strcmp(resultCell(i,2),classes(3)))
            resultCell(i,2) = {3};

        elseif(strcmp(resultCell(i,2),classes(4)))
            resultCell(i,2) = {4};

        elseif(strcmp(resultCell(i,2),classes(5)))
            resultCell(i,2) = {5};
        end
    end

    for i=1:length(proofCell)
        if(strcmp(proofCell(i,2),classes(1)))
            proofCell(i,2) = {1};

        elseif(strcmp(proofCell(i,2),classes(2)))
            proofCell(i,2) = {2};

        elseif(strcmp(proofCell(i,2),classes(3)))
            proofCell(i,2) = {3};

        elseif(strcmp(proofCell(i,2),classes(4)))
            proofCell(i,2) = {4};

        elseif(strcmp(proofCell(i,2),classes(5)))
            proofCell(i,2) = {5};
        end
    end

    resultCell = cell2mat(resultCell);
    %proofCell
    proofCell = cell2mat(proofCell);

    for i=1:length(resultCell)
        resultRow(1,i) = resultCell(i,2);
        proofRow(1,i) = proofCell(i,2);
    end

    dif = resultRow - proofRow;
    %ind = find(dif~=0)
    length(find(proofRow==1));
    length(find(proofRow==2));
    length(find(proofRow==3));
    mistakes = length(find(dif~=0));
    accuracy = 100 - ((100*mistakes)/length(resultCell));

 disp(sprintf('Using Tracks and PHOW: %.2f%%',accuracy));
 %imagesc(confus) ;
 title(sprintf('Confusion matrix Using Tracks (%.2f %% accuracy)',accuracy)) ;
end