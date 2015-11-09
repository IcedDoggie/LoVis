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
    iterator = 0;
    lineArrayTracker = 1;
 
    %Cell matrix for lines of tracks
    IDCount = 0;
    maximumCountID = max(tracksList);     % get the maximum for each column
    maximumCountID = maximumCountID(:,1); % Column is 6, row is the highest no. of ID for cell size.
    
    sizeOfArray = maximumCountID;      % an upper limit for the array size.
    arrayOfLine = zeros(sizeOfArray,2); % Declare outside loop because this must retain info for few frames.
    
    counterForDiffObj = 15758;  % Hardcoded, to be changed later
    arrayOfDiffObj = zeros(maximumCountID,1);
    arrayCount = 1;
    % The loop below is to help in creating cell rows.
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
                    IDCount = IDCount + 1;      % Correction to line 50 Counting-Cow's problem
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
    
    
    matrixForLine = mat2cell(tracksList(:,[3 4 5 6]),arrayOfDiffObj,[4]);
    % initialize Color cell array
    matrixCellColor = cell(maximumCountID,1);
    for a=1 : maximumCountID
        initialColor = {'white'};
        matrixCellColor(a,1) = initialColor;
        
    end

    % initialize singleRowMatrixCell
    singleRowMatrixCell = cell(maximumCountID,1);
    for a=1:maximumCountID
        tempRow = [0 0 0 0];
        tempRow = mat2cell(tempRow,1,4);
        singleRowMatrixCell(a,:) = tempRow;
    end
    
    % initialize currentObject
    currentObjectCell = cell(maximumCountID,1);
    for a=1:maximumCountID
        initialCurrentObject = {'Cars'};
        currentObjectCell(a,1) = initialCurrentObject;
        currentObjectCellConcurrent = currentObjectCell;
    end
    
    
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
                trackInFrame = boundObjects(rowInBoundObjects,2); % is here to do checking for concurrency.
                x = boundObjects(rowInBoundObjects,3);      
                y = boundObjects(rowInBoundObjects,4);
                width = boundObjects(rowInBoundObjects,5);
                height = boundObjects(rowInBoundObjects,6);
                
                positionOfBox = [x y width height];
                
                arrayOfPosition(rowInBoundObjects,:) = positionOfBox(1,:);      % Putting the position into the empty array
                                
                % Determining the object Type( For Bounding Box Titie)
                for currentObjectID = 1:flagLabel                    
                    if(trackID == currentObjectID)
                        currentObjectCell(trackID,1)= objectType(currentObjectID);     % used in line color operation
                        currentObjectCellConcurrent(rowInBoundObjects,1) =  objectType(currentObjectID);  % to be inserted into insertObjectAnnotation
                    end
                end
                
                % Operation to find draw line of tracks
                matrixForLineDouble = matrixForLine{boundObjects(rowInBoundObjects,1),:};     % to select the row to be processed.
                % Determine the middle point
                middlePointX = matrixForLineDouble(:,1) + matrixForLineDouble(:,3)/2;
                middlePointY = matrixForLineDouble(:,2) + matrixForLineDouble(:,4)/2;
                matrixForLineDouble(:,1) = middlePointX;
                matrixForLineDouble(:,2) = middlePointY;
                % Middle point part ends
                matrixForLineDoubleXY = matrixForLineDouble(:,[1 2]);   % to select x and y pos only
                A = (size(matrixForLineDoubleXY));
                A = A(1,1);                    
                singleRowMatrix = zeros(A*2);

                singleRowMatrix = singleRowMatrix(1,:);
                for w=1:flag

                    % Putting the matrix into one single row
                    counterForYPos = 0;
                    counterForRow = 1;
                    for i=1:A*2
                        if(mod(i,2)==0)
                            singleRowMatrix(1,i) = matrixForLineDoubleXY(counterForYPos,2);
                            counterForRow = counterForRow + 1;
                        else
                            singleRowMatrix(1,i) = matrixForLineDoubleXY(counterForRow,1);
                            counterForYPos = counterForYPos + 1; 
                        end
                    end

                    if(A==1)
                        singleRowMatrix = [0 0 0 0];
                    end
                end
                if(A>1)
                    singleRowMatrixConverted = mat2cell(singleRowMatrix,1,A*2);
                    singleRowMatrixCell(trackID,:) = singleRowMatrixConverted;
                end
                % end of operation
                
                % Determining Color for each object              
                currentObjectHelper = char(currentObjectCell{trackID,1});
                   lineColor = {'white'};
                   if(strcmp(currentObjectHelper,'Cars'))
                       lineColor = {'blue'};
                   elseif(strcmp(currentObjectHelper,'Humans')) 
                       lineColor = {'yellow'};
                   elseif(strcmp(currentObjectHelper,'GOP')) 
                       lineColor = {'red'};
                   elseif(strcmp(currentObjectHelper,'Bicycle')) 
                       lineColor = {'green'};                   
                   else
                       lineColor = {'black'};
                   end
                   matrixCellColor(trackID,1) = lineColor; 
                % object Color ends
                
                
                tracksLine = insertShape(videoFrame-videoFrame,'line',singleRowMatrixCell,'color',matrixCellColor);

                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,currentObjectCellConcurrent);
                                
                if(rowInBoundObjects==flag)     % This Line is to avoid iterator moving ahead of videoframes when multiple objects bounded.
                    step(videoPlayer,videoOut+tracksLine); 
                    iterator = iterator + 1;
                end
            
            end
            
            % If no frames detected
            if(flag==0)
%                 tracksLine = insertShape(videoFrame-videoFrame,'line',[0 0 0 0],'color','yellow');
                videoOut = insertObjectAnnotation(videoFrame,'rectangle',arrayOfPosition,'object');
                step(videoPlayer,videoOut); 
                iterator = iterator + 1;
            end
                
%     Print frame number
%     videoOut = insertText(videoOut,[3 3],iterator,'AnchorPoint','LeftTop');

        
       %pause(0.05);
       clear arrayOfPosition;          % Clear the array after each frame
    end

end