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
function dist = lbKeogh(q, c, w, varargin)
for i = 1:2:length(varargin)
    field = lower(varargin{i});
    value = varargin{i+1};
    switch field
        case 'u'
            U = value;
        case 'l'
            L = value;
        case 'square'
            squareRoot = value;
    end
end
if ~exist('U', 'var'), U = zeros(size(q)); end
if ~exist('L', 'var'), L = zeros(size(c)); end
if ~exist('squareRoot', 'var'), squareRoot = false; end

[U, L] = lbKeoghFillUL(q, w, U, L);

dist = sum(sum([(c > U).*(c-U); (c < L).*(L-c)].^2));
if squareRoot, dist = sqrt(dist); end
end