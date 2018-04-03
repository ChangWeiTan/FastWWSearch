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