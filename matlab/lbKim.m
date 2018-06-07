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
function score = lbKim(q, c)
nq = length(q);
nc = length(c);

[minQ, minQIndex] = min(q);
[maxQ, maxQIndex] = max(q);
[minC, minCIndex] = min(c);
[maxC, maxCIndex] = max(c);

diffFirst = (q(1) - c(1))^2;
diffLast = (q(end) - c(end))^2;
score = diffFirst + diffLast;
if minQIndex~=1 && minCIndex~=1 && minQIndex~=nq && minCIndex~=nc
    score = score + (minQ - minC)^2;
end
if maxQIndex~=1 && maxCIndex~=1 && maxQIndex~=nq && maxCIndex~=nc
    score = score + (maxQ - maxC)^2;
end
end