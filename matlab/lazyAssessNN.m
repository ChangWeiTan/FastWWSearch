function [rrt, dtwRes, minValidWindow] = lazyAssessNN(q, indexQ, c, indexC, scoreToBeat, w, cache, costM, pathM, windowM)
dtwRes = -1;
minValidWindow = -1;
if strcmp(cache.stoppedAt(indexQ), 'None')
    minDist = lbKim(q, c);
    cache = cache.setMinDist(indexQ, minDist);
    cache = cache.setBestMinDist(indexQ, minDist);
    cache = cache.setStatus(indexQ, 'Kim');
end
if strcmp(cache.stoppedAt(indexQ), 'Kim')
    if cache.minDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    indexStoppedLB = 1;
    cache = cache.setMinDist(indexQ, 0);
    cache = cache.setStatus(indexQ, 'PartialKeoghQC');
end

if strcmp(cache.stoppedAt(indexQ), 'PartialKeoghQC')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    lbKeoghQC();
    cache = cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    if cache.bestMinDists(indexQ) >= scoreToBeat
        if indexStoppedLB < length(q)
            cache = cache.setStatus(indexQ, 'PartialKeoghQC');
        else
            cache = cache.setStatus(indexQ, 'FullKeoghQC');
        end
        rrt = 'PrunedWithLB';
        return
    else
        cache = cache.setStatus(indexQ, 'FullKeoghQC');
    end
end

if strcmp(cache.stoppedAt(indexQ), 'FullKeoghQC')
    indexStoppedLB = 1;
    cache = cache.setMinDist(indexQ, 0);
    cache = cache.setStatus(indexQ, 'PartialKeoghCQ');
end

if strcmp(cache.stoppedAt(indexQ), 'PartialKeoghCQ')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    lbKeoghCQ();
    cache = cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    if cache.bestMinDists(indexQ) >= scoreToBeat
        if indexStoppedLB < length(q)
            cache = cache.setStatus(indexQ, 'PartialKeoghCQ');
        else
            cache = cache.setStatus(indexQ, 'FullKeoghCQ');
        end
        rrt = 'PrunedWithLB';
        return
    else
        cache = cache.setStatus(indexQ, 'FullKeoghCQ');
    end
end

if strcmp(cache.stoppedAt(indexQ), 'FullKeoghCQ')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    [dtwRes, minValidWindow] = dtw(q, c, 'w', w, ...
        'costmatrix', costM, 'pathmatrix', pathM, 'windowmatrix', windowM);
    cache = cache.setMinDist(indexQ, dtwRes^2);
    cache = cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    cache = cache.setStatus(indexQ, 'DTW');
    cache.dtwDist(indexQ, w+1) = dtwRes^2;
    cache.minValidWindow(indexQ, w+1) = minValidWindow;
end

if strcmp(cache.stoppedAt(indexQ), 'DTW')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithDTW';
        return
    else
        rrt = 'NewBest';
        return
    end
end

    function lbKeoghQC()
        len = length(q);
        [cache,LEQ] = cache.getLE(indexQ, w+1);
        [cache,UEQ] = cache.getUE(indexQ, w+1);
        cache = cache.setMinDist(indexQ, 0);
        indexStoppedLB = 1;
        while indexStoppedLB <= len
            index = cache.getIndexNthHighestVal(indexC, indexStoppedLB);
            cVal = c(index);
            if c < LEQ(index)
                diff = LEQ(index) - cVal;
                cache = cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            elseif UEQ(index) < c
                diff = UEQ(index) - cVal;
                cache = cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            end
            indexStoppedLB = indexStoppedLB + 1;
        end
    end

    function lbKeoghCQ()
        len = length(c);
        [cache,LEC] = cache.getLE(indexC, w+1);
        [cache,UEC] = cache.getUE(indexC, w+1);
        cache = cache.setMinDist(indexQ, 0);
        indexStoppedLB = 1;
        while indexStoppedLB <= len
            index = cache.getIndexNthHighestVal(indexQ, indexStoppedLB);
            qVal = q(index);
            if q < LEC(index)
                diff = LEC(index) - qVal;
                cache = cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            elseif UEC(index) < q
                diff = UEC(index) - qVal;
                cache = cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            end
            indexStoppedLB = indexStoppedLB + 1;
        end
    end
end