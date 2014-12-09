function template_match

    vidPath = '../video/01_david/david.avi';
    outPath = '../video/01_david/out2';

    % Load video
    vid = VideoReader( vidPath);
    origVidFrames = vid.read();
  
    %% Global variable
    global numberOfFrames numberOfRows numberOfCols numberOfRowsTem numberOfColsTem
    numberOfFrames = vid.numberOfFrames;
    numberOfRows = vid.height;
    numberOfCols = vid.width;
    %% End Global viriable

    % Get model 
    frameOne = origVidFrames( :, :, :, 1);
    imshow( frameOne);
    % xmin ymin width height]
    pos = getPosition( imrect);
    grayFrameOne = rgb2gray( frameOne);
    model = grayFrameOne( round( pos(2) : pos(2)+pos(4)), round( pos(1) : pos(1)+pos(3)), :);
    [ numberOfRowsTem, numberOfColsTem,] = size( model);
    
    %Save output video
    vidWriter = VideoWriter( outPath);
    vidWriter.open();
    
    %Tracking
    for k = 2 : 1 : numberOfFrames
        row = round( pos(2));
        col = round( pos(1));
        origFrame = origVidFrames( :, :, :, k);
        grayFrame = rgb2gray( origFrame);
        [ model, bestSimilarity, row, col] = tracking( grayFrame, model, row, col);
        origFrame( [ row, row+numberOfRowsTem-1], col : col+numberOfColsTem-1, 1) = 255;
        origFrame( [ row, row+numberOfRowsTem-1], col : col+numberOfColsTem-1, 2:3) = 0;
        origFrame( row : row+numberOfRowsTem-1, [ col, col+numberOfColsTem-1], 1) = 255;
        origFrame( row : row+numberOfRowsTem-1, [ col, col+numberOfColsTem-1], 2:3) = 0;
        disp( [ 'Frame ' num2str( k) ' : ' num2str( bestSimilarity)]);
        %Show directly
        imshow( origFrame);
        %Save to output video
        vidWriter.writeVideo( origFrame);
    end

    % Save output video
    vidWriter.close();

end %template_match


function [ model, bestSimilarity, row, col] = tracking( frame, model, rowStart, colStart)

    %% Global variable
    global numberOfRowsTem numberOfColsTem;
    %% End Global variable
    
    [ bestSimilarity, row, col] = matchTemplate( frame, model, [ rowStart, colStart]);
    row = round( row);
    col = round( col);
    
    if bestSimilarity > 0.8
        model = frame( row : row + numberOfRowsTem - 1,...
                        col : col + numberOfColsTem -1);
    else
        model = 0.8*frame( row : row + numberOfRowsTem - 1,...
                        col : col + numberOfColsTem -1) + 0.2*model;
    end

end % tracking