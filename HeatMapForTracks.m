function HeatMapForTracks(dataDir,filename)
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    tracksList = load(tracksFile);
    
    posMatrix = tracksList(:,3:4);
    maxCount = numel(posMatrix(:,1));
    
    imageWorld = 'ExpPicture.png';
    
    % Getting the video Frame Size, row and columns 
    videoFile = strcat(dataDir, '\', filename, '.avi');
    videoFileReader = VideoReader(videoFile);
    video = readFrame(videoFileReader);
    vidWidth = videoFileReader.Width;
    vidHeight = videoFileReader.Height;
    
    vidRow = zeros(vidWidth);
    vidRow = vidRow(1,:);
    
    vidColumn = zeros(vidHeight);
    vidColumn = vidColumn(:,1);
        
    % Initializing matrix for heatmapObj
    heatmapMatrix = zeros(vidWidth,vidHeight);
    
    dummyData = heatmapMatrix;


    % Get the max rows and columns from data
    maxRow = posMatrix(:,1);
    maxRow = max(maxRow);
    maxColumn = posMatrix(:,2);
    maxColumn = max(maxColumn);
    
    % Parse in the values from dataset to heatmapMatrix
    for i=1 : maxCount
        singleRowPosX = posMatrix(i,1);
        singleRowPosY = posMatrix(i,2);   
        heatmapMatrix(singleRowPosX,singleRowPosY) = heatmapMatrix(singleRowPosX,singleRowPosY) + 4;
        
        
    end
    
%     for i=1 : 640
%         dummyData(200,i) = 1 + i;
%     end

    %heatmapObj = HeatMap(heatmapMatrix,'ColorMap',redbluecmap,'RowLabels',vidRow,'ColumnLabels',vidColumn);
    %heatmapObj2 = HeatMap(posMatrix,'ColorMap',redbluecmap);
    %heatmapObj3 = HeatMap(heatmapMatrix);
    
%     colormap('jet');
%       imageHeatData = imagesc(heatmapMatrix);
%       colorbar;
%       
      imagesc(dummyData);
      colorbar;
      
      
     % imageOutputCombined = imfuse(imageHeatData,imageWorld);
    
    

end