#include "mex.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

double max(double x, double y) {
	return (x > y) ? x : y;
}

double min(double x, double y) {
	return (x < y) ? x : y;
}

int argMin3(double a, double b, double c) {
	return (a <= b) ? ((a <= c) ? 0 : 2) : (b <= c) ? 1 : 2;
}

void dtw(double *first, double *second, int windowSize, int n, int m, double *dist, double *windowValidity){
    double **costMatrix;
	int **windowMatrix;
	
    int i, j, absIJ, indiceRes;
    int jStart, jEnd, indexInfyLeft;
    double minDist = 0;
	double diff;
    
    costMatrix = (double **)malloc(n*sizeof(double *));
	windowMatrix = (int **)malloc(n*sizeof(int *));
    for(i=0;i<n;i++) {
        costMatrix[i]=(double *)malloc(m*sizeof(double));
		windowMatrix[i]=(int *)malloc(m*sizeof(int));
    }
    
    diff = first[0] - second[0];
	costMatrix[0][0] = diff * diff;
	windowMatrix[0][0] = 0;
	for (i=1;i<min(n, 1+windowSize);i++) {
		diff = first[i] - second[0];
		costMatrix[i][0] = costMatrix[i-1][0] + diff * diff;
		windowMatrix[i][0] = i;
	}
	
	for (j=1;j<min(m, 1+windowSize);j++) {
		diff = first[0] - second[j];
		costMatrix[0][j] = costMatrix[0][j-1] + diff * diff;
		windowMatrix[0][j] = j;
	}
	if (j < m)
		costMatrix[0][j] = INFINITY;
	
	for (i=1;i<n;i++) {
		jStart = max(1,i-windowSize);
		jEnd = min(m, i+windowSize+1);
		indexInfyLeft = i-windowSize-1;
		if (indexInfyLeft >= 0)
			costMatrix[i][indexInfyLeft] = INFINITY;
		
		for (j=jStart;j<jEnd;j++) {
			absIJ = abs(i - j);
            indiceRes = argMin3(costMatrix[i-1][j-1], costMatrix[i][j-1], costMatrix[i-1][j]);
			switch (indiceRes) {
				case 0:
					minDist = costMatrix[i-1][j-1];
					windowMatrix[i][j] = max(absIJ, windowMatrix[i-1][j-1]);
					break;
				case 1:
					minDist = costMatrix[i][j-1];
					windowMatrix[i][j] = max(absIJ, windowMatrix[i][j-1]);
					break;
				case 2:
					minDist = costMatrix[i-1][j];
					windowMatrix[i][j] = max(absIJ, windowMatrix[i-1][j]);
					break;
			}
			
			diff = first[i] - second[j];
			costMatrix[i][j] = minDist + diff * diff;
		}
		if (j < m) 
			costMatrix[i][j] = INFINITY;
	}
	
	dist[0] = costMatrix[n-1][m-1];
    windowValidity[0] = windowMatrix[n-1][m-1];

    for(i=0;i<n;i++){
        free(costMatrix[i]);
		free(windowMatrix[i]);
    }
    free(costMatrix);
	free(windowMatrix);
}

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
	
    if(nrhs <= 2) {
        mexErrMsgIdAndTxt( "DTW:invalidNumInputs", "Two or three inputs required.");
    }
    if(nlhs > 2) {
        mexErrMsgIdAndTxt( "DTW:invalidNumOutputs", "One or Two output required.");
    }
	
	double *first = mxGetPr(prhs[0]);
    double *second = mxGetPr(prhs[1]);
    int windowSize = mxGetScalar(prhs[2]);
	int n = mxGetN(prhs[0]);
	int m = mxGetN(prhs[1]);
	
	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
	
	double *dist = mxGetPr(plhs[0]);
    double *windowValidity = mxGetPr(plhs[1]);
	
	dtw(first,second,windowSize,n,m,dist,windowValidity);
	return;
}
