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
    videoPlayer = vision.VideoPlayer('Position',[300 300 videoInfo.VideoSize+30]);
    %VARIABLE: iterator-> a helper variable in counting video frames
    iterator = 1;
    
    while ~isDone(videoFileReader)
        % Extract next frame
        videoFrame = step(videoFileReader);
 
        
            %Find the object in the specific Frame
            %VARIABLE: boundObjects -> determine the existence of object in a
            %          specifc frame. Output is a matrix. of detected Frames.
            boundObjects = tracksList(tracksList(:,2)==iterator,:);

            % Extract Position of Bounding Box
            %VARIABLE: flag -> return the total number of records inside
            %                  boundObjects.
            flag = size(boundObjects,1);
            positionOfBox = [0 0 0 0];
            
           
    
            if(size(boundObjects)>0)  
                
                for n = 1:flag  
                    
                    trackID = boundObjects(n,1);      
                    x = boundObjects(n,3);      
                    y = boundObjects(n,4);
                    width = boundObjects(n,5);
                    height = boundObjects(n,6);
                    positionOfBox = [x y width height];       

                end
                
            end
            videoOut = insertObjectAnnotation(videoFrame,'rectangle',positionOfBox,'object');      
            step(videoPlayer,videoOut);  
    

    % Determine what kind of object it is
    %         objectType = dataFile(2:end,2);
    %         objectID = dataFile(2:end,1);
    %         if(s==objectID)
    %              objectDisplayed = dataFile(objectID,objectType);
    %         else
    %             objectDisplayed = '-';
    %         end
    % Draw it Out in video frames



    % Print frame number
    %         videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');

        iterator = iterator + 1;
        pause(0.25);
    end

end