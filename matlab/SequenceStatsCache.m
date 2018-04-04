classdef SequenceStatsCache
    properties
        LEs
        UEs
        mins
        maxs
        isMinimumFirst
        isMinimumLast
        isMaximumFirst
        isMaximumLast
        lastWindowComputed
        currentWindow
        train
        indicesSortedByAbsoluteValue
        status
        minDists
        bestMinDists
        dtwDist
        minValidWindow
    end
    methods
        function obj = SequenceStatsCache(train, startingWindow)
            [nSeq, len] = size(train);
           
            obj.train = train;
            obj.LEs = zeros(nSeq, len);
            obj.UEs = zeros(nSeq, len);
            obj.lastWindowComputed = -1 * ones(nSeq, 1);
            obj.currentWindow = startingWindow;
            obj.mins = zeros(nSeq, 1);
            obj.maxs = zeros(nSeq, 1);
            obj.isMinimumFirst = false(nSeq, 1);
            obj.isMinimumLast = false(nSeq, 1);
            obj.isMaximumFirst = false(nSeq, 1);
            obj.isMaximumLast = false(nSeq, 1);
            obj.indicesSortedByAbsoluteValue = zeros(nSeq, len);
            obj.status = cell(nSeq, len);
            obj.minDists = zeros(nSeq, 1);
            obj.bestMinDists = zeros(nSeq, 1);
            obj.dtwDist = zeros(nSeq, 1);
            obj.minValidWindow = zeros(nSeq, 1);
            for i = 1:nSeq
                [minimum, indexMin] = min(train(i, :));
                [maximum, indexMax] = max(train(i, :));
                [~, sortedIndices] = sort(train(i,:), 'descend');
                obj.mins(i) = minimum;
                obj.maxs(i) = maximum;
                obj.isMinimumFirst(i) = indexMin == 1;
                obj.isMinimumLast(i) = indexMin == len;
                obj.isMaximumFirst(i) = indexMax == 1;
                obj.isMaximumLast(i) = indexMin == len;
                obj.indicesSortedByAbsoluteValue(i, :) = sortedIndices;
                obj.status(i, :) = {'None'};
            end
        end
        
        function obj = setMinDist(obj, i, minDist)
            obj.minDists(i) = minDist;
        end
        
        function obj = setBestMinDist(obj, i, bestMinDist)
            obj.bestMinDists(i) = bestMinDist;
        end
        
        function obj = setStatus(obj, i, w, status)
            obj.status{i, w} = status;
        end
        
        function status = stoppedAt(obj, i, w)
            status = obj.status{i, w};
        end
        
        function [obj, LEs] = getLE(obj, i, w) 
            if obj.lastWindowComputed(i) ~= w 
                obj = computeLEandUE(obj, i, w);
            end
            LEs = obj.LEs(i,:);
        end
        
        function [obj, UEs] = getUE(obj, i, w) 
            if obj.lastWindowComputed(i) ~= w 
                obj = computeLEandUE(obj, i, w);
            end
            UEs = obj.UEs(i,:);
        end
        
        function obj = computeLEandUE(obj, i, w)
            [obj.UEs(i,:), obj.LEs(i,:)] = lbKeoghFillUL(obj.train(i, :), w, obj.UEs(i,:), obj.LEs(i,:));
            obj.lastWindowComputed(i)=w;
        end
        
        function flag = isMinFirst(obj, i) 
            flag = obj.isMinimumFirst(i);
        end
        
        function flag = isMinLast(obj, i) 
            flag = obj.isMinimumLast(i);
        end
        
        function flag = isMaxFirst(obj, i) 
            flag = obj.isMaximumFirst(i);
        end
        
        function flag = isMaxLast(obj, i) 
            flag = obj.isMaximumLast(i);
        end
        
        function val = getIndexNthHighestVal(obj, i, n)
            val = obj.indicesSortedByAbsoluteValue(i, n);
        end
    end
end