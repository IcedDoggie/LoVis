function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    videoFileReader = vision.VideoFileReader(video);
    a = load(tracksFile);
   
    
    %fid= fopen(tracksFile);
    
    %==========================================================%
    %                Displaying Box on Video                   %                                         
    %==========================================================%
    

    %b=dlmread(tracksFile,' ',[0 1 iterator 5]);
    %disp(b);
    
    videoInfo = info(videoFileReader);
    videoPlayer = vision.VideoPlayer('Position',[200 200 videoInfo.VideoSize+30]);
    iterator = 1;
    while ~isDone(videoFileReader)
        %Extract next frame
        videoFrame = step(videoFileReader);
        
        %Extract Position of Bounding Box
        
        w = a(iterator,3);
        x = a(iterator,4);
        y = a(iterator,5);
        z = a(iterator,6);
        
        position = [w x y z];  
        
        %Draw it Out in video frames
        videoOut = insertObjectAnnotation(videoFrame,'rectangle',position,'Object');
        
        step(videoPlayer,videoOut);
        iterator = iterator + 1;
       
    end

end