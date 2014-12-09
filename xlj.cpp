#include "mex.h"
#include "opencv2/opencv.hpp"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    unsigned char *ma = ( unsigned char*)mxGetPr( prhs[0]);
    cv::Mat frame( mxGetM( prhs[0]), mxGetN( prhs[0]), CV_8U);
    for( int i = 0; i < frame.rows; ++i){
        for( int j = 0; j < frame.cols; ++j){
            frame.at< unsigned char>( i, j) = *( ma + j*frame.cols + i);
        }
    }
    
    plhs[0] = mxCreateNumericMatrix( frame.rows, frame.cols, mxUINT8_CLASS, mxREAL);
    ma = ( unsigned char*)mxGetPr( plhs[0]);
    for( int i = 0; i < frame.rows; ++i){
        for( int j = 0; j < frame.cols; ++j){
            *( ma + j*frame.cols + i) = frame.at< unsigned char>( i, j);
        }
    }
}