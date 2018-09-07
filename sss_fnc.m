                                                                                function sss_fnc(folderName)

    addpath('../SemanticMatting/rgParameterTuning');
    addpath('../ImageGraphs');

    Fldr = dir(['../Images/', folderName,'/*.png']);
    N = size(Fldr,1);

    for i=4:6 
        imName = Fldr(i).name;
        imName = imName(1:end-4);
        %try
            % Set up image and its corresponding recorded parameters
            recorded = load(['../SemanticMatting/rgParameterTuning/' folderName '_results/' imName '.mat']);
            image = im2double(imread(['../Images/' folderName '/' imName '.png']));
            features = image(:, size(image, 2) / 2 + 1 : end, :);
            image = image(:, 1 : size(image, 2) / 2, :);
            image = imresize(image, 0.5);
            features = imresize(features, 0.5);
            
            % Conduct soft semantic segmentation
            sss = SemanticSoftSegmentation(image, features, recorded);

            % Visualize result
            I = visualizeSoftSegments(sss);
            figure; imshow([image features I]);
            title('Semantic soft segments');
            imwrite([image features I], ['sss_examples/' imName '_withFG' '.png']);
        %catch
        %    disp('failed')
        %end
    end
end