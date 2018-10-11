function formTrimaps(folderName)
    Fldr = dir(['../Files/fga_maps/' folderName '/*.png']);
    N = size(Fldr,1);
    
    for i=1:N
        disp(i);
        trimap = im2double(imread([Fldr(i).folder '/' Fldr(i).name]));
        trimap(trimap>0.9) = 1;
        trimap(trimap<0.1) = 0;
        trimap(trimap>0.1 & trimap<0.9) = 0.5;
        U = trimap==0.5; %unknown region
        U = imdilate(U, ones(3,3));
        trimap(U==1) = 0.5;
        folder = ['../Files/fga_trimaps/' folderName '/'];
        imwrite(trimap, [folder Fldr(i).name]);
    end  
end