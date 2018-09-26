function refineAlphaMaps(folderName)
%REFINEALPHAMAPS Uses AffinityBasedMattingToolbox/informationFlowMatting.m
%to refine the alpha map.
%   Instead of passing a trimap, we only pass the alpha map. Thus we must
%   modify informationFlowMatting.m slightly in line 33: 
%   trimap = im2double(trimap(:,:,1)); -> trimap = im2double(trimap);
    addpath('../AffinityBasedMattingToolbox');


    Fldr = dir(['../Files/fga_maps/' folderName '/*.png']);
    N = size(Fldr,1);
    
    for i=1:N
        imName = Fldr(i).name;
        imName = imName(1:end-4);
        image  = imread(['../Images/' folderName '/' imName '.png']);
        image = image(:,1:end/2,:);
        [h,w,~] = size(image);
        map = imread(['../Files/fga_maps/' folderName '/' imName '.png']);       
        map = imresize(map,[h,w]);
        alpha = informationFlowMatting(image, map);
        imwrite(alpha, ['../Files/fga_maps_refined/' folderName '/' imName '.png']);
    end

end

