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
    global numberOfRows numberOfCols numberOfRowsTem numberOfColsTem;
    %% End Global variable
    
%     rowStart = round( rowStart - numberOfRowsTem);
%     colStart = round( colStart - numberOfColsTem);
%     rowEnd = rowStart + 2*numberOfRowsTem;
%     colEnd = colStart + 2*numberOfColsTem;
%     
%     if rowStart < 1
%         rowStart = 1;
%     end
%     if colStart  < 1
%         colStart = 1;
%     end
%     if rowEnd > ( numberOfRows - numberOfRowsTem + 1)
%         rowEnd = numberOfRows - numberOfRowsTem + 1;
%     end
%     if colEnd > ( numberOfCols - numberOfColsTem + 1)
%         colEnd = numberOfCols - numberOfColsTem + 1;
%     end
%     row = rowStart;
%     col = colStart;
%     bestSimilarity = -Inf;
%     
%     for i = rowStart : 2 : rowEnd
%         for j = colStart : 2 : colEnd
%             similarity = getSimilarity( frame, model, i, j);
%             if similarity > bestSimilarity
%                 bestSimilarity = similarity;
%                 row = i;
%                 col = j;
%             end
%         end
%     end
      
    
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


function similarity = getSimilarity( frame, model, rowStart, colStart)

    %% Global variable
    global numberOfRowsTem numberOfColsTem;
    %% End Global variable
    
%     similarity = sum( sum( ( frame( rowStart : ( rowStart + numberOfRowsTem -1), ...
%                                 colStart : ( colStart + numberOfColsTem - 1))...
%                         - model) .^2));
   
    matchWind = frame( rowStart : (rowStart + numberOfRowsTem -1), ...
                                 colStart : (colStart + numberOfColsTem - 1));
    matchWind = matchWind - mean2( matchWind);
    model  = model - mean2( model);
    similarity = sum( sum( matchWind .* model)) / ...
                    sqrt( sum( sum( matchWind .^ 2)) * sum( sum( model .^ 2)));

end % getSimilarity


