function HeatMapForTracks(dataDir,filename)
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    tracksList = load(tracksFile);
    
    posMatrix = tracksList(:,3:4);
    
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
    
    % Getting the total number of rows
    totalRow = size(posMatrix);
    totalRow = totalRow(1,1);
    totalColumn = 2;
    
    % Initializing matrix for heatmapObj
    heatmapMatrix = zeros(vidWidth,vidHeight);
    
    heatmapMatrix(1:vidWidth,1:vidHeight) = 6;
    
    % Get the max rows and columns from data
    maxRow = posMatrix(:,1);
    maxRow = max(maxRow);
    maxColumn = posMatrix(:,2);
    maxColumn = max(maxColumn);
    
    heatmapObj = HeatMap(heatmapMatrix,'Colormap',redgreencmap,'RowLabels',vidRow,'ColumnLabels',vidColumn);
    

end