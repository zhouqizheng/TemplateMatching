function template_match

    vidPath = '../video/01_david/david.avi';
    outPath = '../video/01_david/out2';

    % Load video
    vid = VideoReader( vidPath);
    
    %Global variable
    global numberOfFrames numberOfRows numberOfCols numberOfRowsTem numberOfColsTem
    numberOfFrames = vid.numberOfFrames;
    numberOfRows = vid.height;
    numberOfCols = vid.width;

    % Get model 
    frameOne = vid.read( 1);
    imshow( frameOne);
    % xmin ymin width height]
    pos = getPosition( imrect);
    grayFrameOne = im2double( rgb2gray( frameOne));
    model = grayFrameOne( round( pos(2) : pos(2)+pos(4)), round( pos(1) : pos(1)+pos(3)), :);
    [ numberOfRowsTem, numberOfColsTem,] = size( model);
    
    %Save output video
    vidWriter = VideoWriter( outPath);
    vidWriter.open();
    
    %Tracking
    for k = 2 : 1 : numberOfFrames
        row = round( pos(2));
        col = round( pos(1));
        origFrame = vid.read( k);
        grayFrame = im2double( rgb2gray( origFrame));
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

%---------------------------------------------------------------------
function [ model, bestSimilarity, row, col] = tracking( frame, model, rowStart, colStart)
    %Global variable
    global numberOfRows numberOfCols numberOfRowsTem numberOfColsTem;
    rowStart = round( rowStart - numberOfRowsTem);
    if rowStart < 1
        rowStart = 1;
    end
    colStart = round( colStart - numberOfColsTem);
    if colStart  < 1
        colStart = 1;
    end
    
%     %% ---------------------------------------------------------------------------
%     rowEnd = rowStart + 3*numberOfRowsTem;
%     if rowEnd > numberOfRows
%         rowEnd = numberOfRows;
%     end
%     colEnd = colStart + 3*numberOfColsTem;
%     if colEnd > numberOfCols
%         colEnd = numberOfCols;
%     end
%     
%     [ bestSimilarity, row, col] = matchTemplate( frame, model, [ rowStart, rowEnd, colStart, colEnd]);
%     row = round( row);
%     col = round( col);
%     %% ---------------------------------------------------------------------------
    
    rowEnd = rowStart + 2*numberOfRowsTem;
    if rowEnd > ( numberOfRows - numberOfRowsTem + 1)
        rowEnd = numberOfRows - numberOfRowsTem + 1;
    end
    colEnd = colStart + 2*numberOfColsTem;
    if colEnd > ( numberOfCols - numberOfColsTem + 1)
        colEnd = numberOfCols - numberOfColsTem + 1;
    end
    
    row = rowStart;
    col = colStart;
    bestSimilarity = -Inf;
    
    for i = rowStart : 2 : rowEnd
        for j = colStart : 2 : colEnd
            similarity = getSimilarity( frame, model, i, j);
            if similarity > bestSimilarity
                bestSimilarity = similarity;
                row = i;
                col = j;
            end
        end
    end
    
%     model = frame( row : row + numberOfRowsTem - 1,...
%                         col : col + numberOfColsTem -1);  
    if bestSimilarity > 0.8
        model = frame( row : row + numberOfRowsTem - 1,...
                        col : col + numberOfColsTem -1);
    else
        model = 0.8*frame( row : row + numberOfRowsTem - 1,...
                        col : col + numberOfColsTem -1) + 0.2*model;
    end

end % tracking

%---------------------------------------------------------------------
function similarity = getSimilarity( frame, model, rowStart, colStart)
    %Global variable
    global numberOfRowsTem numberOfColsTem;
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


