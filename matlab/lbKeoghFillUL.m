function [U, L] = lbKeoghFillUL(q, w, U, L)
for i = 1:length(q)
    jstart = max(1, i-w);
    jend = min(length(q), i+w);
    tmp = q(jstart:jend);
    U(i) = max(tmp);
    L(i) = min(tmp);
end
end