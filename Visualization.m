function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    videoFileReader = vision.VideoFileReader(video);
    a = load(tracksFile);
   
    
    %fid= fopen(tracksFile);
    
    %==========================================================%
    %  Extracting Frames and Object Position from Tracks File  %                                         
    %==========================================================%
    

    %b=dlmread(tracksFile,' ',[0 1 iterator 5]);
    %disp(b);
    
    videoInfo = info(videoFileReader);
    videoPlayer = vision.VideoPlayer('Position',[200 200 videoInfo.VideoSize+30]);
    
    while ~isDone(videoFileReader)
        %Extract next frame
        videoFrame = step(videoFileReader);
        
        %Extract Position of Bounding Box
        
        w = a(:,3);
        x = a(:,4);
        y = a(:,5);
        z = a(:,6);
        
        position = [w x y z];  
        
        %Draw Out 
        videoOut = insertObjectAnnotation(videoFrame,'rectangle',position,'Object');
        
        step(videoPlayer,videoOut);
        
       
    end
    
    % Release resources
     figure, imshow(videoOut);
release(videoFileReader);
release(videoPlayer);
   
    %===========================================================%
    %                  Displaying Box on Video                  %
    %===========================================================%
%     videoFileReader = vision.VideoFileReader(video);
%     videoFrame= step(videoFileReader);
%     
%     videoOut = insertObjectAnnotation(videoFrame,'rectangle',rectangle,'Object');
%     figure, imshow(videoOut), title('LoViS');
end