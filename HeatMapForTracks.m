function HeatMapForTracks(dataDir,filename)
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    tracksList = load(tracksFile);
    
    posMatrix = tracksList(:,3:4);
    maxCount = numel(posMatrix(:,1));
 
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
    heatmapMatrix = zeros(vidHeight,vidWidth);

    % Get the max rows and columns from data
    maxRow = posMatrix(:,1);
    maxRow = max(maxRow);
    maxColumn = posMatrix(:,2);
    maxColumn = max(maxColumn);
    
    % Parse in the values from dataset to heatmapMatrix
    for i=1 : maxCount
        singleRowPosX = posMatrix(i,1);
        singleRowPosY = posMatrix(i,2);   
        heatmapMatrix(singleRowPosY,singleRowPosX) = heatmapMatrix(singleRowPosY,singleRowPosX) + 1;
        if()
        end
    end
    

    %heatmapObj = HeatMap(heatmapMatrix,'ColorMap',redbluecmap,'RowLabels',vidRow,'ColumnLabels',vidColumn);
    %heatmapObj2 = HeatMap(posMatrix,'ColorMap',redbluecmap);
    %heatmapObj3 = HeatMap(heatmapMatrix);
    dataColourMap = jet;
    dataColourMap(1,:) = [1 1 1];
    colormap(dataColourMap);
    imageHeatData = imagesc(heatmapMatrix); %figure    
    colorbar;
        
end