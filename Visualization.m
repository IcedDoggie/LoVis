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
%     matrixCellColor = cell(maximumCountID,1);
    for a=1 : maximumCountID
        initialColor = {'white'};
        matrixCellColor(a,1) = initialColor;
        
    end

    %initialize singleRowMatrixCell
    singleRowMatrixCell = cell(maximumCountID,1);
    for a=1:maximumCountID
        tempRow = [0 0 0 0];
        tempRow = mat2cell(tempRow,1,4);
        singleRowMatrixCell(a,:) = tempRow;
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
                x = boundObjects(rowInBoundObjects,3);      
                y = boundObjects(rowInBoundObjects,4);
                width = boundObjects(rowInBoundObjects,5);
                height = boundObjects(rowInBoundObjects,6);
                
                positionOfBox = [x y width height];
                
                arrayOfPosition(rowInBoundObjects,:) = positionOfBox(1,:);      % Putting the position into the empty array
                                
                % Determining the object Type( For Bounding Box Titie)
                for currentObjectID = 1:flagLabel                    
                    if(trackID == currentObjectID)
                        currentObject = objectType(currentObjectID);
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
%                 currentObjectHelper = char(currentObject);
%                    lineColor = {'white'};
%                    switch currentObjectHelper
%                         case 'Cars'
%                             lineColor = {'blue'};
%                             break;
%                         case 'Humans'
%                             lineColor = {'yellow'};
%                             break;
%                         case 'GOP'
%                             lineColor = {'red'};
%                             break;
%                         case 'Bicycle'
%                             lineColor = {'green'};
%                             break;
%                         case 'Clutter'
%                             lineColor = {'black'};
%                             break;
%                             
%                          
%                     end
              
                % object Color ends
                
                
                tracksLine = insertShape(videoFrame-videoFrame,'line',singleRowMatrixCell,'color',matrixCellColor);

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