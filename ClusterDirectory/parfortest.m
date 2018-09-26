squares = zeros(10,1);
cluster = parcluster('local');
pool = parpool(cluster,4);
parfor i = 1:10
    squares(i) = i^2;
end
save('/cluster/home/squares.m', 'squares');
pool.delete();