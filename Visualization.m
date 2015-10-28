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

    
    %Cell matrix for lines of tracks
    IDCount = 0;
    maximumCountID = max(tracksList);     % get the maximum for each column
    maximumCountID = maximumCountID(:,1); % Column is 6, row is the highest no. of ID for cell size.
    
    counterForDiffObj = 15758;
    arrayOfDiffObj = zeros(maximumCountID,1);
    arrayCount = 1;
    for i=1:counterForDiffObj
        
        if(i==1)
            previousPointer = tracksList(1,1);
            IDCount = IDCount + 1;
        end
        if(i>1)
            currentPointer = tracksList(i,1);
            if(currentPointer == previousPointer)
                IDCount = IDCount + 1;                
            else
                if(IDCount == 0)
                   IDCount = IDCount + 1; 
                
                elseif(arrayCount ~= 1)
                    IDCount = IDCount + 1;      % Correction to line 48 Counting-Cow's problem
                end
                arrayOfDiffObj(arrayCount,1) = IDCount;
                arrayCount = arrayCount + 1;
                IDCount = 0;
            end
          
            previousPointer = currentPointer;
        end
        if(counterForDiffObj == i)
            IDCount = IDCount + 1;
            arrayOfDiffObj(arrayCount,1) = IDCount;
        end
        
    end
    matrixForLine = mat2cell(tracksList,arrayOfDiffObj,[6]);

    
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
                
                middlePointX = (width/2) + x;
                middlePointY = (height/2) + y;
                
                % Storing the middlePoints into an array, so that a
                % progressive line can be plotted.
                
                arrayOfLine(lineArrayTracker,1) = middlePointX;
                arrayOfLine(lineArrayTracker,2) = middlePointY;
                
                if(arrayOfLine(lineArrayTracker,1)~=0 && arrayOfLine(lineArrayTracker,2)~=0)
                    %arrayOfLine(lineArrayTracker,1) = trackID;
                    lineArrayTracker = lineArrayTracker + 1;
                end
                                
                
                
                tracksLine = insertShape(videoFrame-videoFrame,'Line',[ ]);
                
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,currentObject);
                                
                step(videoPlayer,tracksLine+videoOut); 
                
            end
            
            % If no frames detected
            if(flag==0)
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,'object');
                step(videoPlayer,videoOut); 
            end
                
    % Print frame number
    % videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');
        
        iterator = iterator + 1;
        pause(0.5);
        clear arrayOfPosition;          % Clear the array after each frame
    end

end