function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    
    videoFileReader = vision.VideoFileReader(video);
    %VARIABLE: tracksList -> matrix extracted from tracks text file
    tracksList = load(tracksFile);
   
    fid = fopen(dataFile);
    trackdata = textscan(fid, '%d%s', 'delimiter', ',');
    fclose(fid);
    
    
    %fid= fopen(tracksFile);
    
    %==========================================================%
    %                Displaying Box on Video                   %                                         
    %==========================================================%
    

    %b=dlmread(tracksFile,' ',[0 1 iterator 5]);
    %disp(b);
    
    videoInfo = info(videoFileReader);
    videoPlayer = vision.VideoPlayer('Position',[200 200 videoInfo.VideoSize+30]);
    %VARIABLE: iterator-> a helper variable in counting video frames
    iterator = 1;
  
    while ~isDone(videoFileReader)
        % Extract next frame
        videoFrame = step(videoFileReader);
        
        %Find the object in the specific Frame
        %VARIABLE: boundObjects -> determine the existence of object in a
        %specifc frame. Output is a matrix. of detected Frames.
        boundObjects = tracksList(tracksList(:,2)==iterator,:);
            

        % Extract Position of Bounding Box
        
        trackID = a(iterator,1);      
        xPos = a(iterator,3);      
        yPos = a(iterator,4);
        width = a(iterator,5);
        height = a(iterator,6);
        
        position = [x y w h];  
        
        % Determine what kind of object it is
        
%         objectType = dataFile(2:end,2);
%         objectID = dataFile(2:end,1);
%         if(s==objectID)
%              objectDisplayed = dataFile(objectID,objectType);
%         else
%             objectDisplayed = '-';
%         end

        % Draw it Out in video frames
        videoOut = insertObjectAnnotation(videoFrame,'rectangle',position,'object');
    
        % Print frame number
        videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');
        
        step(videoPlayer,videoOut);
        iterator = iterator + 1;
        pause(0.25);
    end

end