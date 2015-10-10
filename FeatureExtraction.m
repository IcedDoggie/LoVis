function FeatureExtraction(dataDir, svmResultDir)

 %*************************************************************************
 %                                Setup 					
 %*************************************************************************

%clear
conf.dataDir = dataDir;
conf.svmResultDir = svmResultDir;
conf.autoDownloadData = false ;
conf.numTrain = 300 ;
conf.numTest = 300 ;
conf.numClasses =  5 ;
conf.numWords = 600 ;
conf.numSpatialX = [2 4] ;
conf.numSpatialY = [2 4] ;
conf.quantizer = 'kdtree' ;
conf.svm.C = 10 ;

%%%%%%%CHOOSE YOUR TRAINING METHOD%%%%%%%%%%

conf.featMethod = 'phow';
%conf.featMethod = 'dsift';
%conf.featMethod = 'sift';
%conf.featMethod = 'phow_dsift';
%conf.featMethod = 'phow_sift';
%conf.featMethod = 'dsift_sift';
%conf.featMethod = 'phow_dsift_sift';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

conf.svm.solver = 'sdca' ;
%conf.svm.solver = 'sgd' ;
%conf.svm.solver = 'liblinear' ;

conf.svm.biasMultiplier = 1 ;
conf.phowOpts = {'Step', 3} ;
conf.clobber = false ;
conf.prefix = conf.featMethod;
conf.randSeed = 1 ;

conf.histPath = fullfile([svmResultDir,'\',conf.prefix,'-hists.mat']);

randn('state',conf.randSeed) ;
rand('state',conf.randSeed) ;
vl_twister('state',conf.randSeed) ;


% --------------------------------------------------------------------
%                                                           Setup data
% --------------------------------------------------------------------
classes = dir(conf.dataDir) ;
classes = classes([classes.isdir]) ;
classes = {classes(3:conf.numClasses+2).name} ;

images = {} ;
imageClass = {} ;
for ci = 1:length(classes)
  ims = dir(fullfile(conf.dataDir, classes{ci}, '*.png'))' ;
  ims = vl_colsubset(ims, conf.numTrain + conf.numTest) ;
  ims = cellfun(@(x)fullfile(classes{ci},x),{ims.name},'UniformOutput',false) ;
  images = {images{:}, ims{:}} ;
  imageClass{end+1} = ci * ones(1,length(ims)) ;
end
selTrain = find(mod(0:length(images)-1, conf.numTrain+conf.numTest) < conf.numTrain) ;
selTest = setdiff(1:length(images), selTrain) ;
imageClass = cat(2, imageClass{:}) ;

model.classes = classes ;
model.phowOpts = conf.phowOpts ;
model.numSpatialX = conf.numSpatialX ;
model.numSpatialY = conf.numSpatialY ;
model.quantizer = conf.quantizer ;
model.vocab = [] ;
model.w = [] ;
model.b = [] ;
model.classify = @classify ;
% --------------------------------------------------------------------
%                                                     Train vocabulary
% --------------------------------------------------------------------



  % Get descriptors to train the dictionary
  selTrainFeats = vl_colsubset(selTrain, 30) ;
  descrs = {};
  %for ii = 1:length(selTrainFeats)
  parfor ii = 1:length(selTrainFeats)
    im = imread(fullfile(conf.dataDir, images{selTrainFeats(ii)})) ;
    im = im2single(im) ;
    switch conf.featMethod
        case {'phow'}
            [f a] = vl_phow(im, model.phowOpts{:});
            descrs{ii} = a;
        case {'dsift'}
            [f a] = vl_dsift(rgb2gray(im));
            descrs{ii} = a;
        case {'sift'}
            [f a] = vl_sift(rgb2gray(im));
            descrs{ii} = a;
        case {'phow_dsift'}
            [f a] = vl_phow(im, model.phowOpts{:});
            [g b] = vl_dsift(rgb2gray(im));
            descrs{ii} = cat(2,a,b);
        case {'phow_sift'}
            [f a] = vl_phow(im, model.phowOpts{:});
            [h c] = vl_sift(rgb2gray(im));
            descrs{ii} = cat(2,a,c);
        case {'dsift_sift'}
            [g b] = vl_dsift(rgb2gray(im));
            [h c] = vl_sift(rgb2gray(im));
            descrs{ii} = cat(2,b,c);
        case {'phow_dsift_sift'}
            [f a] = vl_phow(im, model.phowOpts{:});
            [g b] = vl_dsift(rgb2gray(im)); 
            [h c] = vl_sift(rgb2gray(im));
            descrs{ii} = cat(2,a,b,c);
    end
    
  end
  descrs = vl_colsubset(cat(2, descrs{:}), 10e4) ;
  descrs = single(descrs) ;

  % Quantize the descriptors to get the visual words
  vocab = vl_kmeans(descrs, conf.numWords, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 50) ;
   
  model.vocab = vocab ;

  model.kdtree = vl_kdtreebuild(vocab) ;


% --------------------------------------------------------------------
%                                           Compute spatial histograms
% --------------------------------------------------------------------
if ~exist(conf.histPath)  
  hists = {} ;
  parfor ii = 1:length(images)
    fprintf('Processing %s (%.2f %%)\n', images{ii}, 100 * ii / length(images)) ;
    im = imread(fullfile(conf.dataDir, images{ii})) ;
     switch conf.featMethod
        case {'phow'}
            hists{ii} = getImageDescriptor_PHOW(model, im);
        case {'dsift'}
            hists{ii} = getImageDescriptor_DSIFT(model, im);
        case {'sift'}
            hists{ii} = getImageDescriptor_SIFT(model, im);
        case {'phow_dsift'}
            ph = getImageDescriptor_PHOW(model, im);
            ds = getImageDescriptor_DSIFT(model, im);
            hists{ii} = cat(1,ph,ds);
        case {'phow_sift'}
            ph = getImageDescriptor_PHOW(model, im);
            si = getImageDescriptor_SIFT(model, im);
            hists{ii} = cat(1,ph,si);
        case {'dsift_sift'}
            ds = getImageDescriptor_DSIFT(model, im);
            si = getImageDescriptor_SIFT(model, im);
            hists{ii} = cat(1,ds,si);
        case {'phow_dsift_sift'}
            ph = getImageDescriptor_PHOW(model, im);
            ds = getImageDescriptor_DSIFT(model, im);
            si = getImageDescriptor_SIFT(model, im);
            hists{ii} = cat(1,ph,ds,si);
    end
  end
  hists = cat(2, hists{:}) ;
  save(conf.histPath, 'hists')
else
  load(conf.histPath) ;
end
  
% --------------------------------------------------------------------
%                                                  Compute feature map
% --------------------------------------------------------------------

  psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;

% --------------------------------------------------------------------
%                                                            Train SVM
% --------------------------------------------------------------------

  lambda = 1 / (conf.svm.C *  length(selTrain)) ;
  w = [] ;
  for ci = 1:length(classes)
   perm = randperm(length(selTrain)) ;
   fprintf('Training model for class %s\n', classes{ci}) ;
   y = 2 * (imageClass(selTrain) == ci) - 1 ;
   [w(:,ci) b(ci) info] = vl_svmtrain(psix(:, selTrain(perm)), y(perm), lambda, ...
          'Solver', conf.svm.solver, ...
          'MaxNumIterations', 50/lambda, ...
          'BiasMultiplier', conf.svm.biasMultiplier, ...
          'Epsilon', 1e-3);
  end
 

  model.b = conf.svm.biasMultiplier * b ;
  model.w = w ;
  
% --------------------------------------------------------------------
%                                             Save the Training Result
% --------------------------------------------------------------------

     switch conf.featMethod
        case {'phow'}
            save(fullfile(conf.svmResultDir,'model_PHOW'),'model');
        case {'dsift'}
            save(fullfile(conf.svmResultDir,'model_DSIFT'),'model');
        case {'sift'}
            save(fullfile(conf.svmResultDir,'model_SIFT'),'model');
        case {'phow_dsift'}
            save(fullfile(conf.svmResultDir,'model_CAT_PHOW_DSIFT'),'model');
        case {'phow_sift'}
            save(fullfile(conf.svmResultDir,'model_CAT_PHOW_SIFT'),'model');
        case {'dsift_sift'}
            save(fullfile(conf.svmResultDir,'model_CAT_SIFT_DSIFT'),'model');
        case {'phow_dsift_sift'}
            save(fullfile(conf.svmResultDir,'model_CAT_PHOW_DSIFT_SIFT'),'model');
     end
  
% --------------------------------------------------------------------
%                                                Test SVM and evaluate
% --------------------------------------------------------------------

  % Estimate the class of the test images
  scores = model.w' * psix + model.b' * ones(1,size(psix,2)) ;
  [drop, imageEstClass] = max(scores, [], 1) ;

  % Compute the confusion matrix
  idx = sub2ind([length(classes), length(classes)], ...
              imageClass(selTest), imageEstClass(selTest)) ;
  confus = zeros(length(classes)) ;
  confus = vl_binsum(confus, ones(size(idx)), idx) ;

  %Meng Hao
  rowtotal = sum(confus,2);
  percentScore = diag(confus)./rowtotal*100;
  dat(:,1)=classes';
  cellScore = cellfun(@num2str, num2cell(percentScore), 'UniformOutput', false);
  dat(:,2)=cellScore;
  avg = sum(percentScore);
  disp(avg);
  %Meng Hao

% -------------------------------------------------------------------------
%                                                              Plot Display
% -------------------------------------------------------------------------

  % Plots
  figure(1) ; clf;
  subplot(1,2,1) ;
  imagesc(scores(:,[selTrain selTest])) ; title('Scores') ;
  set(gca, 'ytick', 1:length(classes), 'yticklabel', classes) ;
  subplot(1,2,2) ;
  imagesc(confus) ;
  title(sprintf('Confusion matrix (%.2f %% accuracy )', ...
              100 * sum(diag(confus))/sum(sum(confus)) )) ;

  confus  
          
  %Table
  f = figure(2);
  set(f,'Position',[300 100 300 300]);
  %dat = {classes',percentScore;};
  columnname =   {'Classes', 'Percentage'};
  columnformat = {'char', 'numeric'}; 
    t = uitable('Units','normalized','Position',...
            [0.05 0.05 0.755 0.87], 'Data', dat,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'RowName',[]);
end
