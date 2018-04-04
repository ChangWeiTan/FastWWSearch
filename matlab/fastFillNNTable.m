function nns = fastFillNNTable(train)
[nSeq, len] = size(train);
maxWindow = len;
nns = NearestNeighbour(nSeq, maxWindow);

cache = SequenceStatsCache(train, maxWindow);
costM = inf * ones(len, len);
pathM = -1 * ones(len, len);
windowM = zeros(len, len);

for indexQ = 2:nSeq
    fprintf('Current Series %d - ', indexQ);
    query = train(indexQ, :);
   
    for w = maxWindow-1:-1:0
        fprintf('%d ', w);
        W = w+1;
        if nns.isNN(indexQ, W)
            for indexC = 1:indexQ-1
                candidate = train(indexC, :);
                toBeat = nns.getDistance(indexC, W);
                [rrt, dtwRes, minValidWindow] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache, costM, pathM, windowM);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setNN(indexQ, W, 'FullNN');
                    nns = nns.setIndex(indexQ, W, indexC);
                    nns = nns.setDistance(indexQ, W, dtwRes);
                    nns = nns.setValidWindow(indexQ, W, minValidWindow);
                end
            end
        else
            for indexC = 1:indexQ-1
                candidate = train(indexC, :);
                toBeat = nns.getDistance(indexQ, W);
                [rrt, dtwRes, minValidWindow] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache, costM, pathM, windowM);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setNN(indexQ, W, 'FullNN');
                    nns = nns.setIndex(indexQ, W, indexC);
                    nns = nns.setDistance(indexQ, W, dtwRes);
                    nns = nns.setValidWindow(indexQ, W, minValidWindow);
                end
                
                toBeat = nns.getDistance(indexC, W);
                [rrt, dtwRes, minValidWindow] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache, costM, pathM, windowM);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setNN(indexC, W, 'FullNN');
                    nns = nns.setIndex(indexC, W, indexQ);
                    nns = nns.setDistance(indexC, W, dtwRes);
                    nns = nns.setValidWindow(indexC, W, minValidWindow);
                end
            end
            nnIndex = nns.getIndex(indexQ, W);
            nnDist = nns.getDistance(indexQ, W);
            nnValidWin = nns.getValidWindow(indexQ, W);
            for ww = w:-1:nnValidWin
                nns = nns.setIndex(indexQ, W, nnIndex);
                nns = nns.setDistance(indexQ, W, nnDist);
                nns = nns.setValidWindow(indexQ, W, nnValidWin);
            end
        end
    end
    fprintf('\n');
end
end