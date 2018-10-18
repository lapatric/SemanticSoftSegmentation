% This code extract foreground and background from an image given its alpha
% matte. It is meant to be run on the Euler cluster.
% Must be modified depending on size/resolution of images (HR vs LR), i.e.
% adjust .jpg/.png and *LR/*HR.
status = copyfile('/cluster/scratch/lapatric/images', '$TMPDIR'); disp(status);
status = copyfile('alphasLR', '$TMPDIR'); disp(status);

alphas = dir('$TMPDIR/*a.png'); 
N = size(alphas,1);
disp(N);

cluster = parcluster('local');
%cluster.NumWorkers = 48;
pool = parpool(cluster,12);
parfor i=1:N
    try
        imName = alphas(i).name;
        image = imread(['$TMPDIR/' imName(1:end-5) '.png']);
        alpha = imread(['$TMPDIR/' imName]);
        [h,w,~] = size(image);
        disp(h);
        alpha = imresize(alpha,[h,w]);
        [F,B] = CSLayerColor(image, alpha);
        imwrite(F, ['/cluster/scratch/lapatric/resultsLR/' imName(1:end-5) 'f.png']);
        imwrite(B, ['/cluster/scratch/lapatric/resultsLR/' imName(1:end-5) 'b.png']);
        imName=[]; alpha=[]; image=[]; F=[]; B=[]; % FREE UP MEMORY
    catch
    end
end
pool.delete();
return
