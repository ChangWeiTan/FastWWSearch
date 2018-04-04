% Class for nearest neighbour
classdef NearestNeighbour
    properties
        status      % status: partial or full NN
        index
        distance
        validWin
    end
    methods
        function obj = NearestNeighbour(nSeq, maxWindow)
            obj.index = zeros(nSeq, maxWindow);
            obj.distance = inf * ones(nSeq, maxWindow);
            obj.status = cell(nSeq, maxWindow);
            obj.validWin = zeros(nSeq, maxWindow);
        end
        
        function flag = isNN(obj, i, w)
            flag = strcmp(obj.status{i, w}, 'FullNN');
        end
        
        function obj = setNN(obj, i, w, val)
            obj.status{i, w} = val;
        end
        
        function idx = getIndex(obj, i, w)
            idx = obj.index(i, w);
        end
        
        function obj = setIndex(obj, i, w, val)
            obj.index(i, w) = val;
        end
        
        function distance = getDistance(obj, i, w)
            distance = obj.distance(i, w);
        end
        
        function obj = setDistance(obj, i, w, val)
            obj.distance(i, w) = val;
        end
        
        function win = getValidWindow(obj, i, w)
            win = obj.validWin(i, w);
        end
        
        function obj = setValidWindow(obj, i, w, val)
            obj.validWin(i, w) = val;
        end
    end
end