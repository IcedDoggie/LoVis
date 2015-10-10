function ImageExtraction(filename, dataDir)

    %**********************************************************************
    %                                Setup 					
    %**********************************************************************
    %video input
    video = strcat(dataDir, '\', filename,'.avi');
    %track info input
    labelfile = strcat(dataDir, '\', filename,' - tracks.txt');
    videoObj = VideoReader(video);
    labels = dlmread(labelfile, ' ');
    
    %**********************************************************************
    %               Auto-create folder to make life easier
    %**********************************************************************
    dr = dir(pwd);
    f= filename;
    strtok(f,'.avi');
    mkdir(f);
    %**********************************************************************
    
    %**********************************************************************
    %						Image cropping by labels					
    %**********************************************************************
    m = 2;
    Vref = 320;
    StartOrdinate = 160;
    for i=1:size(labels)
        frame = read(videoObj,labels(i,2));
        im = imcrop(frame, labels(i,3:6));
        if(labels(i,4) > StartOrdinate)
            V = (labels(i,4) + labels(i,4) + labels(i,6)) /2;
            re(i,:) =  m*(Vref/V);
            pic = imresize(im,re(i,:));
        else
            pic = im;
        end
        imwrite(pic,[dataDir, '\', filename '\' num2str(labels(i,1)) '-'   ...
            num2str(labels(i,2)) '.jpg']);
    end

end
