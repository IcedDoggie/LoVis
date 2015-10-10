function TrackExtraction(filename, dataDir)

 %*************************************************************************
 %                                Setup 					
 %*************************************************************************
    % Create System objects used for reading video, detecting moving objects,
    % and displaying the results.
    video = strcat(dataDir, '\',  filename,'.avi');
    % Create track path 
    outputLabels = strcat(dataDir, '\', filename, ' - tracks.txt');
    % Create a video file reader.
     obj.reader = vision.VideoFileReader(video);

    % Create two video players, one to display the video,
    % and one to display the foreground mask.
    %obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    %obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    
    obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 100, 'MinimumBackgroundRatio', 0.7);

    obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 300);
        
    % create an empty array of tracks
    tracks = struct('id', {}, 'frameNo', {}, 'bbox', {}, 'kalmanFilter', {}, 'age', {}, ...
            'totalVisibleCount', {}, 'consecutiveInvisibleCount', {});
        
    nextId = 1; % ID of the next track
    
    trackInfo = []; % Matti
    count = 1; % Matti
    frameNo = 0; % Matti
 %*************************************************************************
 %                      Object Detection and Tracking					
 %*************************************************************************
    % Detect moving objects, and track them across video frames.
    while ~isDone(obj.reader) %read the whole video
    %for i=1:1000 %to read only 1000 frames of the video
        %Read the next video frame from the video file.
        frame = obj.reader.step();
        frameNo = frameNo + 1; % Matti
        [centroids, bboxes, mask] = detectObjects(frame);
        disp(['Frame #',num2str(frameNo),' ',mat2str(centroids,4)])
        
        predictNewLocationsOfTracks();
        [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment();

        updateAssignedTracks();
        updateUnassignedTracks();
        deleteLostTracks();
        createNewTracks();
        
        trimTrackingResults();
        
    end
 %*************************************************************************
 %                               Saving Tracks					
 %*************************************************************************
    saveTracks();
 %*************************************************************************
 %                                  Functions					
 %*************************************************************************
    function [centroids, bboxes, mask] = detectObjects(frame)

        % Detect foreground.
        mask = obj.detector.step(frame);

        % Apply morphological operations to remove noise and fill in holes.
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');

        % Perform blob analysis to find connected components.
        [~, centroids, bboxes] = obj.blobAnalyser.step(mask);
    end

    function predictNewLocationsOfTracks()
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;
                
            % Predict the current location of the track.
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % Shift the bounding box so that its center is at
            % the predicted location.
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
            
            tracks(i).frameNo = frameNo;  % Matti
        end
    end

    function [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment()

        nTracks = length(tracks);
        nDetections = size(centroids, 1);

        % Compute the cost of assigning each detection to each track.
        cost = zeros(nTracks, nDetections);
        for i = 1:nTracks
            cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
        end

        % Solve the assignment problem.
        costOfNonAssignment = 20;
        [assignments, unassignedTracks, unassignedDetections] = ...
            assignDetectionsToTracks(cost, costOfNonAssignment);
    end

    function updateAssignedTracks()
        numAssignedTracks = size(assignments, 1);
        for i = 1:numAssignedTracks
            trackIdx = assignments(i, 1);
            detectionIdx = assignments(i, 2);
            centroid = centroids(detectionIdx, :);
            bbox = bboxes(detectionIdx, :);

            % Correct the estimate of the object's location
            % using the new detection.
            correct(tracks(trackIdx).kalmanFilter, centroid);

            % Replace predicted bounding box with detected
            % bounding box.
            tracks(trackIdx).bbox = bbox;

            % Update track's age.
            tracks(trackIdx).age = tracks(trackIdx).age + 1;

            % Update visibility.
            tracks(trackIdx).totalVisibleCount = ...
                tracks(trackIdx).totalVisibleCount + 1;
            tracks(trackIdx).consecutiveInvisibleCount = 0;
        end
    end

    function updateUnassignedTracks()
        for i = 1:length(unassignedTracks)
            ind = unassignedTracks(i);
            tracks(ind).age = tracks(ind).age + 1;
            tracks(ind).consecutiveInvisibleCount = ...
                tracks(ind).consecutiveInvisibleCount + 1;
        end
    end

    function deleteLostTracks()
        if isempty(tracks)
            return;
        end

        invisibleForTooLong = 1;
        ageThreshold = 8;

        % Compute the fraction of the track's age for which it was visible.
        ages = [tracks(:).age];
        totalVisibleCounts = [tracks(:).totalVisibleCount];
        visibility = totalVisibleCounts ./ ages;

        % Find the indices of 'lost' tracks.
        lostInds = (ages < ageThreshold & visibility < 0.6) | ...
            [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

        % Delete lost tracks.
        tracks = tracks(~lostInds);
    end

    function createNewTracks()
        centroids = centroids(unassignedDetections, :);
        bboxes = bboxes(unassignedDetections, :);

        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);

            % Create a Kalman filter object.
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % Create a new track.
            newTrack = struct(...
                'id', nextId, ...
                'frameNo', frameNo, ... 
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);

            % Add it to the array of tracks.
            tracks(end + 1) = newTrack;

            % Increment the next id.
            nextId = nextId + 1;
        end
    end

    function trimTrackingResults()
        
        minVisibleCount = 5;
        if ~isempty(tracks)
            
            % Noisy detections tend to result in short-lived tracks.
            % Only display tracks that have been visible for more than
            % a minimum number of frames.
            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > minVisibleCount;
            reliableTracks = tracks(reliableTrackInds);
            % Display the objects. If an object has not been detected
            % in this frame, display its predicted bounding box.
            if ~isempty(reliableTracks)
                
                % Matti
                % Saving the tracks in the array to save in text file
                for i=1:length(reliableTracks)
                   trackInfo(count,:) = [reliableTracks(i).id reliableTracks(i).frameNo reliableTracks(i).bbox];
                   count = count + 1;
                end
                % End Matti

            end
        end
    end
    
    %Matti
    function saveTracks()
        trackOutput = sortrows(trackInfo,1);
        newId = 1;
        oldId = trackOutput(1,1);
        trackOutput(1,1) = newId;
        for i=2:length(trackOutput)
           
            if(trackOutput(i,1) ~= oldId)
                newId = newId + 1;
            end
            oldId = trackOutput(i);
            trackOutput(i,1) = newId;
        end
        dlmwrite(outputLabels ,trackOutput,'-append','delimiter',' ');
    end

 %*************************************************************************
 %                              End of Functions					
 %*************************************************************************
 
end