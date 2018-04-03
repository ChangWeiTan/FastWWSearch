function rrt = lazyAssessNN(q, indexQ, c, indexC, scoreToBeat, w, cache, costM, pathM, windowM)
if strcmp(cache.stoppedAt(indexQ), 'None')
    cache.setMinDist(indexQ, lbKim(q, c));
    cache.setBestMinDist(indexQ, minDist);
    cache.setStatus(indexQ, 'Kim');
end
if strcmp(cache.stoppedAt(indexQ), 'Kim')
    if cache.minDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    indexStoppedLB = 0;
    cache.setMinDist(indexQ, 0);
    cache.setStatus(indexQ, 'PartialKeoghQC');
end

if strcmp(cache.stoppedAt(indexQ), 'PartialKeoghQC')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    lbKeoghQC();
    cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    if cache.bestMinDists(indexQ) >= scoreToBeat
        if indexStoppedLB < length(q)
            cache.setStatus(indexQ, 'PartialKeoghQC');
        else
            cache.setStatus(indexQ, 'FullKeoghQC')
        end
        rrt = 'PrunedWithLB';
        return 
    else
        cache.setStatus(indexQ, 'FullKeoghQC')
    end
end

if strcmp(cache.stoppedAt(indexQ), 'FullKeoghQC')
    indexStoppedLB = 0;
    cache.setMinDist(indexQ, 0);
end

if strcmp(cache.stoppedAt(indexQ), 'PartialKeoghCQ')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    lbKeoghCQ();
    cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    if cache.bestMinDists(indexQ) >= scoreToBeat
        if indexStoppedLB < length(q)
            cache.setStatus(indexQ, 'PartialKeoghCQ');
        else
            cache.setStatus(indexQ, 'FullKeoghCQ')
        end
        rrt = 'PrunedWithLB';
        return
    else
        cache.setStatus(indexQ, 'FullKeoghCQ')
    end
end

if strcmp(cache.stoppedAt(indexQ), 'FullKeoghCQ')
    if cache.bestMinDists(indexQ) >= scoreToBeat
        rrt = 'PrunedWithLB';
        return
    end
    [dtwRes, minValidWindow] = dtw(q, c, 'w', w, ...
        'costmatrix', costM, 'pathmatrix', pathM, 'windowmatrix', windowM);
    cache.setMinDist(indexQ, dtwRes^2);
    cache.setBestMinDist(indexQ, max(cache.minDists(indexQ), cache.bestMinDists(indexQ)));
    cache.setStatus(indexQ, 'DTW')
    cache.dtwDist(indexQ, dtwRes^2);
    cache.minValidWindow(indexQ, minValidWindow);
end

if strcmp(cache.stoppedAt(indexQ), 'DTW')
    if bestMinDist >= scoreToBeat
        rrt = 'PrunedWithDTW';
        return
    else
        rrt = 'NewBest';
        return
    end
end

    function lbKeoghQC()
        len = length(q);
        LEQ = cache.getLE(indexQ, w);
        UEQ = cache.getUE(indexQ, w);
        cache.setMinDist(indexQ, 0);
        indexStoppedLB = 0;
        while indexStoppedLB < len
            index = cache.getIndexNthHighestVal(indexC, indexStoppedLB);
            cVal = c(index);
            if c < LEQ(index)
                diff = LEQ(index) - cVal;
                cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            elseif UEQ(index) < c
                diff = UEQ(index) - cVal;
                cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            end
            indexStoppedLB = indexStoppedLB + 1;
        end
    end

    function lbKeoghCQ()
        len = length(c);
        LEC = cache.getLE(indexC, w);
        UEC = cache.getUE(indexC, w);
        cache.setMinDist(indexQ, 0);
        indexStoppedLB = 0;
        while indexStoppedLB < len
            index = cache.getIndexNthHighestVal(indexQ, indexStoppedLB);
            qVal = q(index);
            if q < LEC(index)
                diff = LEC(index) - qVal;
                cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            elseif UEC(index) < q
                diff = UEC(index) - qVal;
                cache.setMinDist(indexQ, cache.minDists(indexQ) + diff^2);
            end
            indexStoppedLB = indexStoppedLB + 1;
        end
    end
end