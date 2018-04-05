function [bestWin, nns, errors] = naiveWWSearch(train, trainClass)
fprintf('Naive Search of the best warping window\n');

[nSeq, len] = size(train);
maxWindow = len + 1;
nns = NearestNeighbour(nSeq, maxWindow);
errors = zeros(maxWindow, 1);
bestErr = nSeq;
bestWin = -1;

for w = 0:maxWindow-1
    W = w+1;
    nns = loocv(train, w, nns);
    
    errCount = 0;
    for i = 1:nSeq
        nnIndex = nns.getIndex(i, W);
        if trainClass(i) ~= trainClass(nnIndex)
            errCount = errCount + 1;
        end
    end
    errors(W) = errCount/nSeq;
    if errCount < bestErr
        bestErr = errCount;
        bestWin = w;
    end
end
fprintf('Best Warping Window: %d\n', bestWin);
end