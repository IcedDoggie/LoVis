function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    a = load(tracksFile);
    
    fid= fopen(tracksFile);
    
    b=dlmread(tracksFile,' ',[0 2 2 5]);
    disp(b);
    
    
    
        
    %end
    %===========================================================%
    %                  Displaying Box on Video                  %
    %===========================================================%
    videoFileReader = vision.VideoFileReader(video);
    videoFrame= step(videoFileReader);
    
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',rectangle,'Object');
    figure, imshow(videoOut), title('LoViS');
end