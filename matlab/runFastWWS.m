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
function [bestWin, nns, errors] = runFastWWS(dataName)
clc; close all;
if nargin < 1
    [Train, TrainClass, ~, ~] = loadData();
else
    fprintf('Loading %s data\n', dataName);
    [Train, TrainClass, ~, ~] = loadData(dataName);
end
% profile on
tic;
[bestWin, nns, errors] = fastWWSearch(Train, TrainClass);
fastWWSTime = toc;
fprintf('FastWWSearch completed in %.3fs\n', fastWWSTime);
% profile viewer

% plot
x = linspace(0, length(errors)-1, length(errors));
figure(1)
clf
plot(x, errors, 'linewidth', 2);
hold on;
plot(bestWin, errors(bestWin+1), 'rx', 'MarkerSize', 8);
hold off;
xlim([0, length(errors)]);
% ylim([0, 1]);
xlabel('Warping Windows, w')
ylabel('Error Rate, e');
title(sprintf('FastWWSearch: Error Rate vs Warping Window - %d', bestWin))
end