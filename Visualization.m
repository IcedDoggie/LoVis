function Visualization(dataDir,filename)
    
    %%% IMPORTANT NOTE:
    %    For the TackLabels_PHOW.dat File, you need to remove the first
    %    line "ID,LABELS" in the dat file manually before using it here.
    %%%
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
    lineArrayTracker = 1;
    sizeOfArray = 100;      % an upper limit for the array size.
    arrayOfLine = zeros(sizeOfArray,2); % Declare outside loop because this must retain info for few frames.
    while ~isDone(videoFileReader)
        
        
        % Extract next frame
        videoFrame = step(videoFileReader);
 
            %                STEP 1                 %     
            % Find the object in the specific Frame %
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
            
            %VARIABLE: boundObjects -> determine the existence of object in a
            %                          specifc frame. Output is a matrix. of detected Frames.
            boundObjects = tracksList(tracksList(:,2)==iterator,:);

            %              STEP 2              %
            % Extract Position of Bounding Box %
            % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
            
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
            
            flagLabel = size(objectID,1);   % to calculate array's size of objectid
            
            % Multiple Object Bounding
            
            arrayOfPosition = zeros(sizeOfArray,4); %initialize 100 empty arrays
            
     
            for rowInBoundObjects = 1:flag  
                
                trackID = boundObjects(rowInBoundObjects,1);      
                x = boundObjects(rowInBoundObjects,3);      
                y = boundObjects(rowInBoundObjects,4);
                width = boundObjects(rowInBoundObjects,5);
                height = boundObjects(rowInBoundObjects,6);
                 
                positionOfBox = [x y width height];
                
                arrayOfPosition(rowInBoundObjects,:) = positionOfBox(1,:);      % Putting the position into the empty array
                                
                % Determining the object Type
                for currentObjectID = 1:flagLabel                    
                    if(trackID == currentObjectID)
                        currentObject = objectType(currentObjectID);
                    end
                end
                
                % Drawing Tracks Line part
                      
                arrayOfLine(lineArrayTracker,1) = x;
                arrayOfLine(lineArrayTracker,2) = y;
                if(arrayOfLine(2,1)>0 && arrayOfLine(2,2)>0 )       % Condition to check whether we have >1 record 
                    for i=1:size(arrayOfLine)
                        j = 1; % initialize
                        if(arrayOfLine(i,1)==0 && arrayOfLine(i,2)==0)
                            break;
                        end
                        if(i>1)
                            j= i-1; %% Indicates the previous row of i
                        end
                        
                        x1 = arrayOfLine(j,1);
                        y1 = arrayOfLine(j,2);
                        x2 = arrayOfLine(i,1);
                        y2 = arrayOfLine(i,2);
                        
                    end
                    tracksLine = insertShape(videoFrame-videoFrame,'Line',[x1 y1 x2 y2]);  % videoFrame-videoFrame, omitting the background of frames  
                else
                    tracksLine = insertShape(videoFrame-videoFrame,'Line',[0 0 0 0]);
                end
                
                % End of drawing Tracks Line
                
                
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,currentObject);
                                
                step(videoPlayer,tracksLine+videoOut); 
                lineArrayTracker = lineArrayTracker + 1;
            end
            
            % If no frames detected
            if(flag==0)
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,'object');
                step(videoPlayer,videoOut); 
            end
                
    % Print frame number
    % videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');
        
        iterator = iterator + 1;
        
        clear arrayOfPosition;          % Clear the array after each frame
    end

end