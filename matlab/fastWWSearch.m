function bestWin = fastWWSearch(train, trainClass)
nns = fastFillNNTable(train);
[nSeq, len] = size(train);
bestErr = len;
bestWin = -1;
for w = 0:len-1
    errCount = 0;
    for i = 1:nSeq
        nnIndex = nns.getIndex(i, w+1);
        if trainClass(i) ~= trainClass(nnIndex)
            errCount = errCount + 1;
        end
    end
    if errCount < bestErr
        bestErr = errCount;
        bestWin = w;
    end
end
fprintf('Best Warping Window: %d\n', bestWin);
end