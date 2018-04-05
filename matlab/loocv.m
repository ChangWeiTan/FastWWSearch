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
            [dtwDist, minValidWindow] = dtw(query, candidate, 'w', w, ...
                'costmatrix', costM, 'pathmatrix', pathM, ...
                'windowmatrix', windowM, 'square', true);
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