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
function [bestWin, nns, errors] = naiveWWSearch(train, trainClass)
disp('NaiveWWSearch...');

[nSeq, len] = size(train);
maxWindow = len + 1;

nns = NearestNeighbour(nSeq, maxWindow);
errors = zeros(maxWindow, 1);
bestErr = nSeq;
bestWin = -1;

disp('LOOCV...');
for w = 0:maxWindow-1
    W = w+1;
    nns = loocv(train, w, nns);
    
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
fprintf('NaiveWWSearch done, Best Warping Window: %d\n', bestWin);
end

function nns = loocv(train, w, nns)
[nSeq, len] = size(train);
U = zeros(1, len);
L = zeros(1, len);
costM = inf * ones(len);
pathM = -1 * ones(len);
windowM = zeros(len);

W = w+1;

for i = 1:nSeq
    query = train(i, :);
    bsfDist = inf;
    [U, L] = lbKeoghFillUL(query, w, U, L);
    for j = 1:nSeq
        if j == i, continue; end
        candidate = train(j, :);
        lbDist = lbKeogh(query, candidate, w, 'U', U, 'L', L, 'square', true);
        if lbDist < bsfDist
            [dtwDist, minValidWindow] = dtw(query, candidate, w);
            if dtwDist < bsfDist
                bsfDist = dtwDist;
                nns = nns.setIndex(i, W, j);
                nns = nns.setDistance(i, W, dtwDist);
                nns = nns.setValidWindow(i, W, minValidWindow);
            end
        end
    end
end
end