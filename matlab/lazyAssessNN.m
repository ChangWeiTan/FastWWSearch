function [rrt, dtwRes, minValidWindow, cache] = lazyAssessNN(q, iQ, ...
    c, iC, scoreToBeat, w, cache, costM, pathM, windowM)
if iQ < iC
    query = q;
    indexQ = iQ;
    candidate = c;
    indexC = iC;
else
    query = c;
    indexQ = iC;
    candidate = q;
    indexC = iQ;
end

status = cache.stoppedAt(indexQ, indexC);
minDist = cache.minDists(indexQ, indexC);
bestMinDist = cache.bestMinDists(indexQ, indexC);
minValidWindow = cache.validWin(indexQ, indexC);
dtwRes = bestMinDist;

if strcmp(status, 'None')
    minDist = lbKim(query, candidate);
    bestMinDist = minDist;
    status = 'Kim';
elseif strcmp(status, 'DTW')
    if w >= minValidWindow
        status = 'DTW';
    else
        status = 'PreviousWindowDTW';
    end
else
    status = 'PreviousWindowLB';
end

if strcmp(status, 'Kim') || ... 
        strcmp(status, 'PreviousWindowDTW') || ...
        strcmp(status, 'PreviousWindowLB')
    % if start from here, has to go through all process
    if bestMinDist >= scoreToBeat
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
        return
    end
    status = 'PartialKeoghQC';
    minDist = 0;
end
if strcmp(status, 'PartialKeoghQC')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
        return
    end
    [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, query, indexQ, candidate, indexC, w);
    if minDist > bestMinDist
        bestMinDist = minDist;
    end
    if bestMinDist >= scoreToBeat
        if indexStoppedLB < length(query)
            status = 'PartialKeoghQC';
        else
            status = 'FullKeoghQC';
        end
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
    else
        status = 'FullKeoghQC';
    end
end
if strcmp(status, 'FullKeoghQC')
    minDist = 0;
    status = 'PartialKeoghCQ';
end
if strcmp(status, 'PartialKeoghCQ')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
        return
    end
    [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, candidate, indexC, query, indexQ, w);
    if minDist > bestMinDist
        bestMinDist = minDist;
    end
    if bestMinDist >= scoreToBeat
        if indexStoppedLB < length(candidate)
            status = 'PartialKeoghCQ';
        else
            status = 'FullKeoghCQ';
        end
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
    else
        status = 'FullKeoghCQ';
    end
end
if strcmp(status, 'FullKeoghCQ')
    if bestMinDist >= scoreToBeat 
        rrt = 'PrunedWithLB';
        cache = cache.setMinDist(indexQ, indexC, minDist);
        cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
        cache = cache.setStatus(indexQ, indexC, status);
        return
    end
    [dtwRes, minValidWindow] = dtw(query, candidate, 'w', w, ...
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
    cache = cache.setMinDist(indexQ, indexC, minDist);
    cache = cache.setBestMinDist(indexQ, indexC, bestMinDist);
    cache = cache.setValidWin(indexQ, indexC, minValidWindow);
    cache = cache.setStatus(indexQ, indexC, status);
    if bestMinDist >= scoreToBeat
        rrt = 'PrunedWithDTW';
        return
    else
        rrt = 'NewBest';
        return
    end
end
end

function [cache, minDist, indexStoppedLB] = tryLbKeogh(cache, q, indexQ, c, indexC, w)
len = length(q);
W = w+1;
[cache,LEQ] = cache.getLE(indexQ, W);
[cache,UEQ] = cache.getUE(indexQ, W);
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