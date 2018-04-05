% Class for nearest neighbour
classdef NearestNeighbour
    properties
        index
        distance
        validWin
    end
    methods
        function obj = NearestNeighbour(nSeq, maxWindow)
            obj.index = -1 * ones(nSeq, maxWindow);
            obj.distance = inf * ones(nSeq, maxWindow);
            obj.validWin = -1 * ones(nSeq, maxWindow);
        end
        
        function flag = isNN(obj, i, w)
            flag = (obj.index(i, w) >= 0) && ...
                (obj.distance(i, w) < inf) && (obj.validWin(i, w) >= 0);
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