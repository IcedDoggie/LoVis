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
        posX = posMatrix(i,1);
        posY = posMatrix(i,2);   
        heatmapMatrix(posY,posX) = heatmapMatrix(posY,posX) + 1;
        if(posY~=1 && posY~=480 && posX~=1 && posX~=640)
%             % Upper left corner pixel
%             x1 = posX - 1;
%             y1 = posY - 1;
%             heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.5;
            
            % Upper middle pixel
            x1 = posX + 0;
            y1 = posY - 1;
            heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.75;
%             
%             % Upper right corner pixel
%             x1 = posX + 1;
%             y1 = posY - 1;
%             heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.5;
            
            % Left Pixel
            x1 = posX - 1;
            y1 = posY + 0;
            heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.75;
            
            % Right Pixel
            x1 = posX + 1;
            y1 = posY + 0;
            heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.75;
%             
%             % Lower Left Corner Pixel
%             x1 = posX - 1;
%             y1 = posY + 1;
%             heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.5;
%             
            % Lower middle pixel
            x1 = posX + 0;
            y1 = posY + 1;
            heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.75;
%             
%             % Lower right corner pixel
%             x1 = posX + 1;
%             y1 = posY + 1;
%             heatmapMatrix(y1,x1) = heatmapMatrix(y1,x1) + 0.5;            
            
        end
    end
    
    
    % Displaying ColorMap
    computedMatrix = log10(1+heatmapMatrix+eps);
    dataColourMap = jet;
    dataColourMap(1,:) = [1 1 1];
    colormap(dataColourMap);
    imageHeatData = imagesc(computedMatrix); %figure    
    colorbar;
   

    % Read and convert background picture
%     image = imread('background.png');
%     image = rgb2gray(image);
%     imshow(image);
%     hold on;
%         
%     % Image Overlay
%     imageFuse = imread('withoutNeighbours.png')
%     imshow(imageFuse);

end