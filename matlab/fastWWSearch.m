%**************************************************************************
% Copyright (C) 2018 Chang Wei TAN, Matthieu HERRMANN, Germain FORESTIER,
%                          Geoff WEBB, Francois PETITJEAN
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, version 3 of the License.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.well
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
% Author: Chang Wei Tan (chang.tan@monash.edu)
%*************************************************************************/ 
function [bestWin, nns, errors] = fastWWSearch(train, trainClass)
disp('FastWWSearch...');
[nSeq, len] = size(train);
maxWindow = len + 1;

nns = fastFillNNTable(train);
errors = zeros(maxWindow, 1);
bestErr = nSeq;
bestWin = -1;

disp('One Pass NN Table...');
for w = 0:maxWindow-1
    W = w+1;
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
fprintf('FastWWSearch done, Best Warping Window: %d\n', bestWin);
end

function nns = fastFillNNTable(train, PRINT)
if nargin < 2, PRINT = false; end

disp('FastFillNNTable...');
[nSeq, len] = size(train);      % get the size of the training set
maxWindow = len + 1;            % window from 0 to L, therefore L+1 windows

% initialise nearest neighbour class
nns = NearestNeighbour(nSeq, maxWindow);
% initialise cache
cache = SequenceStatsCache(train, maxWindow);

for indexQ = 2:nSeq 
    if PRINT, fprintf('Sequence %d\n', indexQ); end
    
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
                    toBeat, w, cache);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setIndex(indexC, W, indexQ);
                    nns = nns.setDistance(indexC, W, dtwRes);
                    nns = nns.setValidWindow(indexC, W, minValidWindow);
                end
            end
        else
            % check query against all candidates
            % sort the candidates based on bestMinDists in ascending order
            [~, sortIndex] = sort(cache.bestMinDists(1:indexQ-1),'ascend');
            for t = 1:indexQ-1
                indexC = sortIndex(t);
                candidate = train(indexC, :);
                
                % update NNs[query][w]
                toBeat = nns.getDistance(indexQ, W);
                [rrt, dtwRes, minValidWindow, cache] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeat, w, cache);
                if strcmp(rrt, 'NewBest')
                    nns = nns.setIndex(indexQ, W, indexC);
                    nns = nns.setDistance(indexQ, W, dtwRes);
                    nns = nns.setValidWindow(indexQ, W, minValidWindow);
                end
                
                % update NNs[candidate][w] if needed to
                toBeatC = nns.getDistance(indexC, W);
                [rrtC, dtwRes, minValidWindow, cache] = ...
                    lazyAssessNN(query, indexQ, candidate, indexC, ...
                    toBeatC, w, cache);
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
disp('FastFillNNTable done');
end

function [rrt, dtwRes, minValidWindow, cache] = lazyAssessNN(q, iQ, ...
    c, iC, scoreToBeat, w, cache)
% Assess a potential Nearest neighbour candidate in a lazy manner
% swap the query and candidate based on the indexes in training set
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

% initialise
status = cache.stoppedAt(indexQ, indexC);
minDist = cache.minDists(indexQ, indexC);
bestMinDist = cache.bestMinDists(indexQ, indexC);
minValidWindow = cache.validWin(indexQ, indexC);
dtwRes = bestMinDist;

if strcmp(status, 'None')
    % if haven't done anything to this pair, do LB Kim
    minDist = lbKim(query, candidate);
    bestMinDist = minDist;
    status = 'Kim';
elseif strcmp(status, 'DTW')
    if w >= minValidWindow 
        % if DTW has been computed and w still valid
        status = 'DTW';
    else
        % if DTW has been computed and w not valid
        status = 'PreviousWindowDTW';
    end
else
    % or else we have computed a lower bound
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
    [cache, minDist, indexStoppedLB] = doLbKeogh(cache, query, ...
        indexQ, candidate, indexC, w);
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
        return
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
    [cache, minDist, indexStoppedLB] = doLbKeogh(cache, candidate, ...
        indexC, query, indexQ, w);
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
        return
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
    [dtwRes, minValidWindow] = dtw(query, candidate, w);
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

function [cache, minDist, indexStoppedLB] = doLbKeogh(cache, q, ...
    indexQ, c, indexC, w)
% can apply early abandon here

len = length(q);
W = w+1;
% get the upper and lower envelopes from cache
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