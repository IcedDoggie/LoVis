function Majority_Vote(filename, dataDir, svmResultDir)

    labels = dlmread(strcat(dataDir, '\', filename,' - tracks.txt'), ' ');
    Matti.dataDir = strcat(dataDir, '\', filename, '\');
    Matti.TrainingPath = svmResultDir;

    featMethod = 'phow';
    %featMethod = 'dsift';
    %featMethod = 'sift';
    %featMethod = 'cat_phow_dsift';
    %featMethod = 'cat_phow_sift';
    %featMethod = 'cat_dsift_sift';
    %featMethod = 'cat_phow_dsift_sift';

    switch featMethod
        case {'phow'}
            Matti.ModelDir = 'model_PHOW.mat';
        case {'dsift'}
            Matti.ModelDir = 'model_DSIFT.mat';
        case {'sift'}
            Matti.ModelDir = 'model_SIFT.mat';
        case {'cat_phow_dsift'}
            Matti.ModelDir = 'model_CAT_PHOW_DSIFT.mat';
        case {'cat_phow_sift'}
            Matti.ModelDir = 'model_CAT_PHOW_SIFT.mat';
        case {'cat_dsift_sift'}
            Matti.ModelDir = 'model_CAT_SIFT_DSIFT.mat';
        case {'cat_phow_dsift_sift'}
            Matti.ModelDir = 'model_CAT_PHOW_DSIFT_SIFT.mat';
    end

    Matti.model = load(fullfile(Matti.TrainingPath,Matti.ModelDir));

    model= Matti.model.model;

    %*****************************************************************************************
    %											
    %*****************************************************************************************
    classes = zeros(1,5);

    for i=1:size(labels,1)

        im = imread(strcat(Matti.dataDir,num2str(labels(i,1)),'-',num2str(labels(i,2)), '.jpg'));
        switch featMethod
            case {'phow'}
                hista = getImageDescriptor_PHOW(model, im) ;
            case {'dsift'}
                hista = getImageDescriptor_DSIFT(model, im) ;
            case {'sift'}
                hista = getImageDescriptor_SIFT(model, im) ;
            case {'cat_phow_dsift'}
                ph = getImageDescriptor_PHOW(model, im);
                ds = getImageDescriptor_DSIFT(model, im);
                hista= cat(1,ph,ds);
            case {'cat_phow_sift'}
                ph = getImageDescriptor_PHOW(model, im);
                si = getImageDescriptor_SIFT(model, im);
                hista = cat(1,ph,si);
            case {'cat_dsift_sift'}
                ds = getImageDescriptor_DSIFT(model, im);
                si = getImageDescriptor_SIFT(model, im);
                hista = cat(1,ds,si);
            case {'cat_phow_dsift_sift'}
                ph = getImageDescriptor_PHOW(model, im);
                ds = getImageDescriptor_DSIFT(model, im);
                si = getImageDescriptor_SIFT(model, im);
                hista = cat(1,ph,ds,si);
        end

        psix = vl_homkermap(hista, 1, 'kchi2', 'gamma', .5) ;
        scores = model.w' * psix + model.b' ;
        [score, best] = max(scores) ;
        className = model.classes{best} ;


        if(i==1)
           switch(best)
            case 1  
               classes(1,1) = classes(1,1) + 1; 
            case 2  
               classes(1,2) = classes(1,2) + 1;
            case 3  
                classes(1,3) = classes(1,3) + 1; 
            case 4 
                classes(1,4) = classes(1,4) + 1; 
            case 5 
                classes(1,5) = classes(1,5) + 1; 
            end
        else
            if labels(i,1) == labels(i-1,1)
                switch(best)
                    case 1  
                        classes(1,1) = classes(1,1) + 1; 
                    case 2  
                        classes(1,2) = classes(1,2) + 1;
                    case 3  
                        classes(1,3) = classes(1,3) + 1; 
                    case 4 
                        classes(1,4) = classes(1,4) + 1; 
                    case 5 
                        classes(1,5) = classes(1,5) + 1; 
                end
            else

               [maxValue index] = max(classes(1,:));
               labelClass{labels(i-1,1),1} = num2str(labels(i-1,1));
               labelClass{labels(i-1,1),2} = model.classes{index};
               labelPrediction = strcat(num2str(labels(i-1,1)) ,' - ' ,model.classes{index});
               labelPrediction
               classes = zeros(1,5);

               switch(best)
                    case 1  
                        classes(1,1) = classes(1,1) + 1; 
                    case 2  
                        classes(1,2) = classes(1,2) + 1;
                    case 3  
                        classes(1,3) = classes(1,3) + 1; 
                    case 4 
                        classes(1,4) = classes(1,4) + 1; 
                    case 5 
                        classes(1,5) = classes(1,5) + 1; 
                end
           end
        end       

        %imwrite(pic,[filename '\' num2str(labels(i,1)) '-'   ...
            %num2str(labels(i,2)) '.png']);
    end
    [maxValue index] = max(classes(1,:));
    labelClass{labels(i,1),1} = num2str(labels(i,1));
    labelClass{labels(i,1),2} = model.classes{index};

    T = cell2table(labelClass,'VariableNames',{'Label','ClassName'});
     switch featMethod
        case {'phow'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_PHOW.dat')));
        case {'dsift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_DSIFT.dat')));
        case {'sift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_SIFT.dat'))); 
        case {'cat_phow_dsift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_CAT_PHOW_DSIFT.dat')));     
        case {'cat_phow_sift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_CAT_PHOW_SIFT.dat')));     
        case {'cat_dsift_sift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_CAT_DSIFT_SIFT.dat')));     
        case {'cat_phow_dsift_sift'}
           writetable(T,fullfile(strcat(dataDir, '\', filename,' - TackLabels_CAT_PHOW_DSIFT_SIFT.dat'))); 
    end
end