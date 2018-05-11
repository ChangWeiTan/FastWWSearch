function nns = fastFillNNTable(train)
[nSeq, len] = size(train);      % get the size of the training set
maxWindow = len + 1;            % window from 0 to L, therefore L+1 windows

% initialise the matrices for DTW computations 
costM = inf * ones(len, len);   % cost matrix
pathM = -1 * ones(len, len);    % matrix for the warping path 
windowM = zeros(len, len);      % window validity matrix

% initialise nearest neighbour class
nns = NearestNeighbour(nSeq, maxWindow);
% initialise cache
cache = SequenceStatsCache(train, maxWindow);

for indexQ = 2:nSeq 
    % update NNs table by adding a query one by one
    query = train(indexQ, :);
    
    for w = maxWindow-1:-1:0
        W = w+1; 
        if nns.isNN(indexQ, W)
            % if we already have NN of query for w
            % update the table for NNs[candidates][w]
            for indexC = 1:indexQ-1
                candidate = train(indexC, :);
                
                % distance between candidate and its NN
                toBeat = nns.getDistance(indexC, W);
                [rrt, dtwRes, minValidWindow, cache] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache, costM, pathM, windowM);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setIndex(indexC, W, indexQ);
                    nns = nns.setDistance(indexC, W, dtwRes);
                    nns = nns.setValidWindow(indexC, W, minValidWindow);
                end
            end
        else
            % check query against all candidates
            % sort the candidates based on bestMinDists in ascending order
            [~, sortIndex] = sort(cache.bestMinDists(1:indexQ-1), 'ascend');
            for t = 1:indexQ-1
                indexC = sortIndex(t);
                candidate = train(indexC, :);
                
                % update NNs[query][w]
                toBeat = nns.getDistance(indexQ, W);
                [rrt, dtwRes, minValidWindow, cache] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache, costM, pathM, windowM);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setIndex(indexQ, W, indexC);
                    nns = nns.setDistance(indexQ, W, dtwRes);
                    nns = nns.setValidWindow(indexQ, W, minValidWindow);
                end
                
                % update NNs[candidate][w] if needed to
                toBeatC = nns.getDistance(indexC, W);
                [rrtC, dtwRes, minValidWindow, cache] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeatC, w, cache, costM, pathM, windowM);
                if strcmp(rrtC, 'NewBest')
                    nns = nns.setIndex(indexC, W, indexQ);
                    nns = nns.setDistance(indexC, W, dtwRes);
                    nns = nns.setValidWindow(indexC, W, minValidWindow);
                end
            end
            
            % propagate NN for all valid path
            nnIndex = nns.getIndex(indexQ, W);
            nnDist = nns.getDistance(indexQ, W);
            nnValidWin = nns.getValidWindow(indexQ, W);
            for ww = w:-1:nnValidWin
                WW = ww+1;
                nns = nns.setIndex(indexQ, WW, nnIndex);
                nns = nns.setDistance(indexQ, WW, nnDist);
                nns = nns.setValidWindow(indexQ, WW, nnValidWin);
            end
        end
    end
end
end