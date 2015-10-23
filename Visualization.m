function Visualization(dataDir,filename)
    video = strcat(dataDir, '\', filename, '.avi' );
    dataFile = strcat(dataDir, '\', filename, ' - TackLabels_PHOW.dat');
    tracksFile = strcat(dataDir,'\', filename, ' - tracks.txt');
    
    
    videoFileReader = vision.VideoFileReader(video);
    %VARIABLE: tracksList -> matrix extracted from tracks text file
    tracksList = load(tracksFile);
    fid = fopen(dataFile);
    trackData = textscan(fid, '%d%s', 'delimiter', ',');
    fclose(fid);
    
    
    %fid= fopen(tracksFile);
    
    %==========================================================%
    %                Displaying Box on Video                   %                                         
    %==========================================================%
    

    %b=dlmread(tracksFile,' ',[0 1 iterator 5]);
    %disp(b);
    
    videoInfo = info(videoFileReader);
    videoPlayer = vision.VideoPlayer('Position',[400 0 videoInfo.VideoSize+30]);
    %VARIABLE: iterator-> a helper variable in counting video frames
    iterator = 1;
    counter = 1;
    while ~isDone(videoFileReader)
        
        
        % Extract next frame
        videoFrame = step(videoFileReader);
 
            %                STEP 1               %     
            %Find the object in the specific Frame%
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
            
            %VARIABLE: boundObjects -> determine the existence of object in a
            %                          specifc frame. Output is a matrix. of detected Frames.
            boundObjects = tracksList(tracksList(:,2)==iterator,:);

            %              STEP 2            %
            %Extract Position of Bounding Box%
            %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
            
            %VARIABLE: flag -> return the total number of records inside
            %                  boundObjects.
            %VARIABLE: multipleObjectFlag -> helps to draw multiple
            %                                bounding box appearing in same frame.
            %VARIABLE: rowInBoundObjects -> return the rows in boundObjects
            %                               matrix
            flag = size(boundObjects,1);
            positionOfBox = [0 0 0 0];  
            
            % Determining Objects  
            objectType = trackData(:,2);
            objectID = trackData(:,1);
 
            objectID = cell2mat(objectID);
            
            objectType = objectType{1};
            
            
     
            for rowInBoundObjects = 1:flag  
                trackID = boundObjects(rowInBoundObjects,1);      
                x = boundObjects(rowInBoundObjects,3);      
                y = boundObjects(rowInBoundObjects,4);
                width = boundObjects(rowInBoundObjects,5);
                height = boundObjects(rowInBoundObjects,6);
                positionOfBox = [x y width height];
                
                currentObjectID = objectID(counter,1);
              
                if(trackID == currentObjectID)
                    counter = counter + 1;
                    currentObject = objectType(trackID);
                   
                end
                
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',positionOfBox,currentObject);
               
                step(videoPlayer,videoOut); 
               
            end
            
            if(flag==0)
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',positionOfBox,'object');
                 step(videoPlayer,videoOut); 
            end
                






    % Print frame number
    %         videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');

        iterator = iterator + 1;
        pause(0.25);
    end

end