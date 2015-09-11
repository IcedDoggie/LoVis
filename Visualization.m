function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    
    videoFileReader = vision.VideoFileReader(video);
    a = load(tracksFile);
   
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
%     iterator = 1;
  
    while ~isDone(videoFileReader)
        %Extract next frame
        videoFrame = step(videoFileReader);
        
        %Find the object in the specific Frame
        
        
        %Extract Position of Bounding Box
        
%         s = a(iterator,1);      % track id
%         x = a(iterator,3);      % 
%         y = a(iterator,4);
%         w = a(iterator,5);
%         h = a(iterator,6);
%         
%         position = [x y w h];  
        
        %Determine what kind of object it is
        objectType = dataFile(2:end,2);
        objectID = dataFile(2:end,1);
        if(s==objectID)
             objectDisplayed = dataFile(objectID,objectType);
        else
            objectDisplayed = '-';
        end
        %Draw it Out in video frames
        videoOut = insertObjectAnnotation(videoFrame,'rectangle',position,objectDisplayed);
    
        % Print frame number
        videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');
        
        step(videoPlayer,videoOut);
%         iterator = iterator + 1;
        pause(0.25);
    end

end