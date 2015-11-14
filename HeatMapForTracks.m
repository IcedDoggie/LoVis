function HeatMapForTracks(dataDir,filename)
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    tracksList = load(tracksFile);
    
    posMatrix = tracksList(:,3:4);
    
    % Getting the video Frame Size
    videoFile = strcat(dataDir, '\', filename, '.avi');
    videoFileReader = VideoReader(videoFile);
    video = readFrame(videoFileReader);
    vidWidth = videoFileReader.Width;
    vidHeight = videoFileReader.Height;
    
    % Getting the total number of rows
    totalRow = size(posMatrix);
    totalRow = totalRow(1,1);
    totalColumn = 2;
    
    % Convert Row and Columns to cell
%     totalRowCell = cell(totalRow,1); 
%     for i = 1:totalRow
%         singleRow = posMatrix(i,1:2);
%         totalRowCell(i,1) = {singleRow}; 
%     end
    
    % Get the max rows and columns from data
    maxRow = posMatrix(:,1);
    maxRow = max(maxRow);
    maxColumn = posMatrix(:,2);
    maxColumn = max(maxColumn);
    
    heatmapObj = HeatMap(posMatrix,'Colormap',redbluecmap,'RowLabels',vidHeight,'ColumnLabels',vidWidth);
    

end