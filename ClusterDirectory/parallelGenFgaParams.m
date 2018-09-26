% This function is used to precompute the soft segments and distinguish the
% initially activated foreground segments. The results are then saved.
%addpath('../SemanticMatting/rgParameterTuning');
%addpath('../ImageGraphs');
Fldr = dir('params/*.mat');
N = size(Fldr,1);

cluster = parcluster('local');
%cluster.NumWorkers = 48;
pool = parpool(cluster,24);
results = cell(N,3);
parfor i=1:N
    try
        imName = Fldr(i).name;
        imName = imName(1:end-4);

        %% Set up image and its corresponding recorded parameters
        param = load(['params/' imName '.mat']);
        image = im2double(imread(['images/' imName '.png']));
        features = image(:, size(image, 2) / 2 + 1 : end, :);
        image = image(:, 1 : size(image, 2) / 2, :);
        image = imresize(image, 0.5);
        features = imresize(features, 0.5);

        %% Conduct soft semantic segmentation to obtain soft segments using my recorded parameters    
        % Prepare the inputs and superpixels
        image = im2double(image);
        if size(features, 3) > 3 % If the features are raw, hyperdimensional, preprocess them
            features = preprocessFeatures(features, image);
        else
            features = im2double(features);
        end
        superpixels = Superpixels(image);
        [h, w, ~] = size(image);

        disp('     Computing affinities')
        % Compute the affinities and the Laplacian
        affI = mattingAffinity(image);
        erfCenter = param.paramValue;
        affII = superpixels.neighborAffinities(features, [], erfCenter); % semantic affinity
        affIII = superpixels.nearbyAffinities(image); % non-local color affinity
        Laplacian = affinityMatrixToLaplacian(affI + 0.01 * affII + 0.01 * affIII); % Equation 6
        affI = []; affII = []; affIII = []; superpixels = []; % FREE UP MEMORY
        
        disp('     Computing eigenvectors')
        % Compute the eigendecomposition
        eigCnt = 100; % We use 100 eigenvectors in the optimization
        [eigenvectors, eigenvalues] = eigs(Laplacian, eigCnt, 'SM');

        disp('     Initial optimization')
        % Compute initial soft segments
        initialSegmCnt = 40;
        sparsityParam = 0.8;
        iterCnt = 40;
        % feeding features to the function below triggers semantic intialization
        initSoftSegments = softSegmentsFromEigs(eigenvectors, eigenvalues, Laplacian, ...
                                                h, w, features, initialSegmCnt, iterCnt, sparsityParam, [], []);    
        eigenvectors = []; eigenvalues = []; % FREE UP MEMORY
                                            
        %% Initialize foreground alpha using groupSegments function and my foreground markings
        segments = initSoftSegments;
        initSoftSegments = []; % FREE UP MEMORY
        fg = param.fgXY;
        segmCnt = 5;
        [h, w, cnt] = size(segments);
        compFeatures = zeros(cnt, size(features, 3));
        for k = 1 : cnt
            cc = segments(:,:,k) .* features;
            cc = sum(sum(cc, 1), 2) / sum(sum(segments(:,:,k), 1), 2);
            compFeatures(k, :) = cc;
        end

        ids = kmeans(compFeatures, segmCnt);
        compFeatures = []; % FREE UP MEMORY
        % Conjoin segments that are touched by the 'foreground marker'!
        % All segments belonging to foreground are written to "segment layer 1".
        fg = round(fg/2);   
        idxs = sub2ind([h,w], fg(:,2), fg(:,1));
        j = 2;
        activeSegments = ids;
        for l = 1 : segmCnt
            segment = sum(segments(:,:,ids==l), 3);
            segmentMask = round(segment);
            intersection = segmentMask(idxs);
            if sum(intersection) > 0
                activeSegments(activeSegments==l) = 1;
            else               
                activeSegments(activeSegments==l) = 0;
                j = j+1;
            end
        end 

        results(i,:) = {imName, segments, activeSegments};
        imName = []; segments = []; activeSegments = []; % FREE UP MEMORY
    catch
    end
end
save('results.mat', 'results', '-v7.3');
pool.delete();
