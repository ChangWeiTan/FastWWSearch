function [bestWin, nns, errors] = fastWWSearch(train, trainClass)
[nSeq, len] = size(train);
maxWindow = len + 1;

nns = fastFillNNTable(train);
errors = zeros(maxWindow, 1);
bestErr = len;
bestWin = -1;

for w = 0:maxWindow-1
    W = w+1;
    errCount = 0;
    for i = 1:nSeq
        nnIndex = nns.getIndex(i, w+1);
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