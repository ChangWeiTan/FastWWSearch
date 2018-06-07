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
function [bestWin,nns,errors,bestWinFastWWS,nnsFastWWS,errorsFastWWS]=run()
clc; close all;

[Train, TrainClass, ~, ~] = loadData();

tic;
[bestWinFastWWS, nnsFastWWS, errorsFastWWS] = fastWWSearch(Train, TrainClass);
fastWWSTime = toc;
fprintf('FastWWSearch completed in %.3fs\n', fastWWSTime);

tic;
[bestWin, nns, errors] = naiveWWSearch(Train, TrainClass);
naiveTime = toc;
fprintf('NaiveWWSearch completed in %.3fs\n', naiveTime);

% plot
x = linspace(0, length(errors)-1, length(errors));
figure(1)
clf
plot(x, errors, 'b', 'linewidth', 2);
hold on;
plot(x, errorsFastWWS, 'r', 'linewidth', 2);
plot(bestWin, errors(bestWin+1), 'gx', 'MarkerSize', 8);
plot(bestWinFastWWS, errorsFastWWS(bestWin+1), 'go', 'MarkerSize', 8);
hold off;
xlim([0, length(errors)]);
% ylim([0, 1]);
xlabel('Warping Windows, w')
ylabel('Error Rate, e');
title(sprintf('Error Rate vs Warping Window - (%d,%d)',bestWin,bestWinFastWWS))
end