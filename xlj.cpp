#include "mex.h"
#include "opencv2/opencv.hpp"

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    
    unsigned char *prm = ( unsigned char*)mxGetPr( prhs[0]);
    cv::Mat frame( mxGetM( prhs[0]), mxGetN( prhs[0]), CV_32F);
    for( int i = 0; i < frame.rows; ++i){
        for( int j = 0; j < frame.cols; ++j){
            frame.at< float>( i, j) = *( prm + j*frame.rows + i);
        }
    }
    
    plhs[0] = mxCreateDoubleMatrix( frame.rows, frame.cols, mxREAL);
    double *plm = mxGetPr( plhs[0]);
    for( int i = 0; i < frame.rows; ++i){
        for( int j = 0; j < frame.cols; ++j){
            *( plm + j*frame.rows + i) = frame.at< float>( i, j);
        }
    }
}