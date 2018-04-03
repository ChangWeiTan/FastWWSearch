function dist = distanceTo(a,b)
dist=squaredDist(a, b);
end

function dist = squaredDist(a, b)
dist=(a-b)^2;
end