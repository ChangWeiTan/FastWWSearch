function dist = lbKeogh(q, c, w, varargin)
for i = 1:length(varargin)
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

[U, L] = lbKeoghFillUL(q, w, U, L);

dist = sum(sum([(c > U).*(c-U); (c < L).*(L-c)].^2));
if squareRoot, dist = sqrt(dist); end
end