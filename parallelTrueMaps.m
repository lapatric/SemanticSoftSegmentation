% Creates true foreground maps using informationFlowMatting (written for  
% computer cluster).
addpath('AffinityBasedMattingToolbox');
status = copyfile('/cluster/scratch/lapatric/images', '$TMPDIR');
disp(status);
status = copyfile('repeattrimaps', '$TMPDIR');
disp(status);
%rmdir('/cluster/scratch/lapatric/images');

trimaps = dir('$TMPDIR/*.png'); 
N = size(trimaps,1);
disp(N);

cluster = parcluster('local');
%cluster.NumWorkers = 48;
pool = parpool(cluster,8);
parfor i=1:N
    try
        imName = trimaps(i).name;
        trimap = imread(['$TMPDIR/' imName]);
        image = imread(['$TMPDIR/' imName(1:end-4) '.jpg']);
	[h,w,~] = size(image);
        disp(h);
        trimap = imresize(trimap,[h,w]);
        map = informationFlowMatting(image, trimap);        
        imwrite(map, ['/cluster/scratch/lapatric/results/' imName(1:end-4) '.jpg']);
        imName=[]; trimap=[]; image=[]; map=[]; % FREE UP MEMORY
    catch
    end
end
pool.delete();
return