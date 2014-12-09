function template_match

    vidPath = '../video/01_david/david.avi';
    outPath = '../video/01_david/out';

    % Load video
    vid = VideoReader( vidPath);
    origVidFrames = vid.read();
    vidFrames = 0.299*origVidFrames( :, :, 1, :) + 0.587*origVidFrames( :, :, 2, :) ...
                + 0.114*origVidFrames( :, :, 3, :);
    sz = size( vidFrames);
    vidFrames = reshape( vidFrames, sz(1), sz(2), sz(4));
    
    
    %Global variable
    global numberOfFrames numberOfRows numberOfCols numberOfRowsTem numberOfColsTem
    numberOfFrames = sz(4);
    numberOfRows = sz(1);
    numberOfCols = sz(2);

    % Get model 
    frameOne = vidFrames( :, :, 1);
    imshow( frameOne);
    % xmin ymin width height]
    pos = getPosition( imrect);
    model = frameOne( round( pos(2) : pos(2)+pos(4)), round( pos(1) : pos(1)+pos(3)), :);
    [ numberOfRowsTem, numberOfColsTem,] = size( model);
    
    %Save output video
    vidWriter = VideoWriter( outPath);
    vidWriter.open();
    
    %Tracking
    for k = 2 : 1 : numberOfFrames
        row = round( pos(2));
        col = round( pos(1));
        grayFrames = vidFrames( :, :, k);
        [ model, row, col] = tracking( grayFrames, model, row, col);
        origVidFrames( [ row, row+numberOfRowsTem-1], col : col+numberOfColsTem-1, 1, k) = 255;
        origVidFrames( [ row, row+numberOfRowsTem-1], col : col+numberOfColsTem-1, 2:3, k) = 0;
        origVidFrames( row : row+numberOfRowsTem-1, [ col, col+numberOfColsTem-1], 1, k) = 255;
        origVidFrames( row : row+numberOfRowsTem-1, [ col, col+numberOfColsTem-1], 2:3, k) = 0;
        disp( k);
        %Show directly
        imshow( origVidFrames( :, :, :, k));
        %Save to output video
        vidWriter.writeVideo( origVidFrames( :, :, :, k));
    end

    % Save output video
    vidWriter.close();

end %template_match

%---------------------------------------------------------------------
function [ model, row, col] = tracking( frame, model, rowStart, colStart)
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
    
    %% ---------------------------------------------------------------------------
    rowEnd = rowStart + 3*numberOfRowsTem;
    if rowEnd > numberOfRows
        rowEnd = numberOfRows;
    end
    colEnd = colStart + 3*numberOfColsTem;
    if colEnd > numberOfCols
        colEnd = numberOfCols;
    end
    
    [ bestSimilarity, row, col] = matchTemplate( frame, model, [ rowStart, rowEnd, colStart, colEnd]);
    row = round( row);
    col = round( col);
    
    %% ---------------------------------------------------------------------------
%     rowEnd = rowStart + 2*numberOfRowsTem;
%     if rowEnd > ( numberOfRows - numberOfRowsTem + 1)
%         rowEnd = numberOfRows - numberOfRowsTem + 1;
%     end
%     colEnd = colStart + 2*numberOfColsTem;
%     if colEnd > ( numberOfCols - numberOfColsTem + 1)
%         colEnd = numberOfCols - numberOfColsTem + 1;
%     end
%     
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
    
%     model = frame( row : row + numberOfRowsTem - 1,...
                        col : col + numberOfColsTem -1);
    disp( bestSimilarity);
    if bestSimilarity > 0.2
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


