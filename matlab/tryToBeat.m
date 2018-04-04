function [rrt, dtwRes, minValidWindow, cache] = tryToBeat(q, indexQ, c, indexC, scoreToBeat, w, cache, costM, pathM, windowM, dtwRes, minValidWindow)
if strcmp(cache.stoppedAt(indexQ, w+1), 'DTW')
    if w >= minValidWindow
        status = 'DTW';
        bestMinDist = cache.bestMinDists(indexQ);
        minDist = cache.minDists(indexQ);
    else, status = 'PreviousWindowDTW'; end
elseif strcmp(cache.stoppedAt(indexQ, w+1), 'None')
    minDist = lbKim(q, c);
    bestMinDist = minDist;
    status = 'Kim';
else
    status = 'PreviousWindowLB';
    bestMinDist = cache.bestMinDists(indexQ);
    minDist = cache.minDists(indexQ);
end

if strcmp(status, 'Kim') || ... 
        strcmp(status, 'PreviousWindowDTW') || ...
        strcmp(status, 'PreviousWindowLB')
    if bestMinDist >= scoreToBeat
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    end
    indexStoppedLB = 1;
    minDist = 0;
    status = 'PartialKeoghQC';
end
if strcmp(status, 'PartialKeoghQC')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    end
    [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, q, indexQ, c, indexC, w);
    if minDist > bestMinDist
        bestMinDist = minDist;
    end
    if bestMinDist >= scoreToBeat
        if indexStoppedLB < length(q), status = 'PartialKeoghQC';
        else, status = 'FullKeoghQC'; end
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
    else
        status = 'FullKeoghQC';
    end
end
if strcmp(status, 'FullKeoghQC')
    indexStoppedLB = 1;
    minDist = 0;
    status = 'PartialKeoghCQ';
end
if strcmp(status, 'PartialKeoghCQ')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    end
    [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, c, indexC, q, indexQ, w);
    if minDist > bestMinDist
        bestMinDist = minDist;
    end
    if bestMinDist >= scoreToBeat
        if indexStoppedLB < length(q), status = 'PartialKeoghCQ';
        else, status = 'FullKeoghCQ'; end
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
    else
        status = 'FullKeoghCQ';
    end
end
if strcmp(status, 'FullKeoghCQ')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    end
    [dtwRes, minValidWindow] = dtw(q, c, 'w', w, ...
        'costmatrix', costM, 'pathmatrix', pathM, ...
        'windowmatrix', windowM, 'square', true);
    dtwRes = dtwRes^2;
    minDist = dtwRes;
    if minDist > bestMinDist
        bestMinDist = minDist;
    end
    status = 'DTW';
end
if strcmp(status, 'DTW')
    if bestMinDist >= scoreToBeat
        rrt = 'PrunedWithDTW';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    else
        rrt = 'NewBest';
        cache = cache.setMinDist(indexQ, minDist);
        cache = cache.setBestMinDist(indexQ, bestMinDist);
        cache = cache.setStatus(indexQ, w+1, status);
        return
    end
end

end

function [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, q, indexQ, c, indexC, w)
len = length(q);
[cache,LEQ] = cache.getLE(indexQ, w+1);
[cache,UEQ] = cache.getUE(indexQ, w+1);
minDist = 0;
indexStoppedLB = 1;
while indexStoppedLB <= len
    index = cache.getIndexNthHighestVal(indexC, indexStoppedLB);
    cVal = c(index);
    if cVal < LEQ(index)
        diff = LEQ(index) - cVal;
        minDist = minDist + diff^2;
    elseif UEQ(index) < cVal
        diff = UEQ(index) - cVal;
        minDist = minDist + diff^2;
    end
    indexStoppedLB = indexStoppedLB + 1;
end
end
