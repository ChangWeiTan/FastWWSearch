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
function [U, L] = lbKeoghFillUL(q, w, U, L)
for i = 1:length(q)
    jstart = max(1, i-w);
    jend = min(length(q), i+w);
    tmp = q(jstart:jend);
    U(i) = max(tmp);
    L(i) = min(tmp);
end
end