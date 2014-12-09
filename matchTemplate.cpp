#include "mex.h"
#include "opencv2/opencv.hpp"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    if( nlhs != 3 || nlhs != 3 || nrhs != 3){
        mexPrintf( "Usage : [similarity, rowStart, colStart] = matchTemplate( frame, model, [rowStart, rowEnd, colStart, colEnd]\n");
        return ;
    }
    
    // Copy mxArray fram to cv::Mat frame
    unsigned char *ma = ( unsigned char*)mxGetPr( prhs[0]);
    cv::Mat frame( mxGetM( prhs[0]), mxGetN( prhs[0]), CV_8U);
    for( int i = 0; i < frame.rows; ++i){
        for( int j = 0; j < frame.cols; ++j){
            frame.at< unsigned char>( i, j) = *( ma + j*frame.rows + i);
        }
    }
    
    // Copy mxArray template to cv::Mat template
    ma = ( unsigned char*)mxGetPr( prhs[1]);
    cv::Mat model( mxGetM( prhs[1]), mxGetN( prhs[1]), CV_8U);
    for( int i = 0; i < model.rows; ++i){
        for( int j = 0; j < model.cols; ++j){
            model.at< unsigned char>( i, j) = *( ma + j*model.rows + i);
        }
    }
    
    // Get range parameter
    double *range = mxGetPr( prhs[2]);
    
    // Match
    cv::Rect searchWindow;  
    searchWindow.width = model.cols * 3;  
    searchWindow.height = model.rows * 3;  
    searchWindow.x = range[1] - 1 + model.cols * 0.5 - searchWindow.width * 0.5;  
    searchWindow.y = range[0] - 1 + model.rows * 0.5 - searchWindow.height * 0.5;  
    searchWindow &= cv::Rect(0, 0, frame.cols, frame.rows);
    
    cv::Mat similarityMat;
    cv::matchTemplate( frame( searchWindow), model, similarityMat, CV_TM_CCOEFF_NORMED);
    double bestSimilarity;  
    cv::Point point;  
    cv::minMaxLoc(similarityMat, 0, &bestSimilarity, 0, &point);
    
    // return
    plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL);
    *mxGetPr( plhs[0]) = bestSimilarity;
    plhs[1] = mxCreateDoubleMatrix( 1, 1, mxREAL);
    *mxGetPr( plhs[1]) = point.y + searchWindow.y + 1;
    plhs[2] = mxCreateDoubleMatrix( 1, 1, mxREAL);
    *mxGetPr( plhs[2]) =  point.x + searchWindow.x + 1;
}