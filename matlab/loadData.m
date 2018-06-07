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
function [Train, TrainClass, Test, TestClass] = loadData(dataName) 
if nargin < 1
    % load sample data (ItalyPowerDemand)
    load('sampleTrain.mat');
    load('sampleTest.mat');
    return;
end
tscProblem = 'C:\Users\cwtan\workspace\Dataset\TSC_Problems';
trainName = sprintf('%s\\%s\\%s_Train.txt', tscProblem, dataName, dataName);
testName = sprintf('%s\\%s\\%s_Test.txt', tscProblem, dataName, dataName);

Train = load(trainName);
TrainClass = Train(:, 1);
Train(:, 1) = [];

Test = load(testName);
TestClass = Test(:, 1);
Test(:, 1) = [];

end