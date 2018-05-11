function [dist, minValidWindow, costM, pathM, windowM] = dtw2(q, c, varargin)
diag = 0;
left = 1;
up = 2;

for i = 1:2:length(varargin)
    field = lower(varargin{i});
    value = varargin{i+1};
    switch field
        case {'w', 'window', 'warpingwindow'}
            W = value;
        case 'costmatrix'
            costM = value;
        case 'pathmatrix'
            pathM = value;
        case 'windowmatrix'
            windowM = value;
        case 'square'
            squareRoot = value;
    end
end
nq = length(q);
nc = length(c);

if ~exist('W', 'var'), W = min(nq, nc); end
if ~exist('costM', 'var'), costM = inf * ones(nq, nc); end
if ~exist('pathM', 'var'), pathM = -1 * ones(nq, nc); end
if ~exist('windowM', 'var'), windowM = zeros(nq, nc); end
if ~exist('squareRoot', 'var'), squareRoot = false; end

mq = min(nq, W+1);
mc = min(nc, W+1);

costM(1,1) = distanceTo(q(1),c(1));
pathM(1,1) = -1;
for i=2:mq
    costM(i,1)= costM(i-1,1) + distanceTo(q(i),c(1));
    pathM(i,1) = up;
    windowM(i,1) = i-1;
end
for i=2:mc
    costM(1,i)= costM(1,i-1) + distanceTo(q(1),c(i));
    pathM(1,i) = left;
    windowM(1,i) = i-1;
end
if i < nc, costM(i, i) = inf; end

for i=2:nq
    jstart = max(2, i-W);
    jend = min(nc, i+W);
    indexInfLeft = i-W;
    if indexInfLeft >= 1, costM(i, indexInfLeft) = inf; end
    
    for j=jstart:jend
        [res, indiceRes] = min([costM(i-1,j-1),costM(i,j-1),costM(i-1,j)]);
        indiceRes = indiceRes-1;
        pathM(i,j) = indiceRes;
        costM(i,j) = distanceTo(q(i),c(j)) + res;
        switch(indiceRes)
            case diag
                windowM(i,j) = max(windowM(i-1,j-1), abs(i-j));
            case left
                windowM(i,j) = max(windowM(i,j-1), abs(i-j));
            case up
                windowM(i,j) = max(windowM(i-1,j), abs(i-j));
        end
    end
    if (j+1) < nc, costM(i, j+1) = inf; end
end
dist = costM(nq,nc);
if squareRoot, dist = sqrt(dist); end
costM(isinf(costM)) = NaN;
minValidWindow = windowM(nq, nc);
end