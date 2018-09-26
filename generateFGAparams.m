% This function is used to precompute the soft segments and distinguish the
% initially activated foreground segments. The results are then saved.
function generateFGAparams(folderName)
    addpath('../SemanticMatting/rgParameterTuning');
    addpath('../ImageGraphs');

    Fldr = dir(['../Images/', folderName,'/*.png']);
    N = size(Fldr,1);
    
    for i=153:N
        try
            imName = Fldr(i).name;
            imName = imName(1:end-4);

            %% Set up image and its corresponding recorded parameters
            params = load(['../Files/sss_params/' folderName '/' imName '.mat']);
            image = im2double(imread(['../Images/' folderName '/' imName '.png']));
            features = image(:, size(image, 2) / 2 + 1 : end, :);
            image = image(:, 1 : size(image, 2) / 2, :);
            image = imresize(image, 0.5);
            features = imresize(features, 0.5);

            %% Conduct soft semantic segmentation to obtain soft segments using my recorded parameters    
            disp('Semantic Soft Segmentation')
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
            affinities{1} = mattingAffinity(image);
            erfCenter = params.paramValue;
            affinities{2} = superpixels.neighborAffinities(features, [], erfCenter); % semantic affinity
            affinities{3} = superpixels.nearbyAffinities(image); % non-local color affinity
            Laplacian = affinityMatrixToLaplacian(affinities{1} + 0.01 * affinities{2} + 0.01 * affinities{3}); % Equation 6

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

            %% Initialize foreground alpha using groupSegments function and my foreground markings
            segments = initSoftSegments;
            fg = params.fgXY;
            segmCnt = 5;
            [h, w, cnt] = size(segments);
            compFeatures = zeros(cnt, size(features, 3));
            for i = 1 : cnt
                cc = segments(:,:,i) .* features;
                cc = sum(sum(cc, 1), 2) / sum(sum(segments(:,:,i), 1), 2);
                compFeatures(i, :) = cc;
            end

            ids = kmeans(compFeatures, segmCnt);
            groupedSegments = zeros(h, w, segmCnt);   
            % Conjoin segments that are touched by the 'foreground marker'!
            % All segments belonging to foreground are written to "segment layer 1".
            fg = round(fg/2);   
            idxs = sub2ind(size(groupedSegments(:,:,1)), fg(:,2), fg(:,1));
            j = 2;
            activeSegments = ids;
            for i = 1 : segmCnt
                segment = sum(segments(:,:,ids==i), 3);
                segmentMask = round(segment);
                intersection = segmentMask(idxs);
                if sum(intersection) > 0
                    activeSegments(activeSegments==i) = 1;
                else               
                    activeSegments(activeSegments==i) = 0;
                    j = j+1;
                end
            end 

            %% NOTE: The combination of initSoftSegments and activeSegments then
             % yields the alphas of the foreground. We save these
            folder = ['../Files/fga_params/' folderName '/'];
            save([folder imName '.mat'], 'initSoftSegments', 'activeSegments');

%             fg_matte = zeros(h,w);
%             for k=1:cnt
%                 if activeSegments(k)==1
%                     fg_matte = fg_matte + initSoftSegments(:,:,k);
%                 end
%             end
%             imshow(fg_matte);
%             visualizeSoftSegments(initSoftSegments);
        catch
            disp(['Failed to process ' imName '.png!']);
        end
    end
end