function correctFGAlphas(folderName)
    Fldr = dir(['../Files/fga_params/' folderName '/*.mat']);
    N = size(Fldr,1);
    currNmbr = load(['../Files/fga_params/' folderName '/currNmbr.mat']);
    k = currNmbr.i;
     
    figure('DeleteFcn',@figDelete);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    imageAxes = subplot(1,3,1,'Parent', gcf);
    fgAlphaAxes = subplot(1,3,2,'Parent', gcf);
    alphaVisAxes = subplot(1,3,3,'Parent', gcf);
    
    for i=k:N 
        fileName = Fldr(i).name;
        data = load(['../Files/fga_params/' folderName '/' fileName]);
        active = data.active;
        initSoftSegments = data.segments;
                         
        [h,w,cnt] = size(initSoftSegments);
        fg_matte = zeros(h,w);
        for k=1:cnt
            if active(k)==1
                fg_matte = fg_matte + initSoftSegments(:,:,k);
            end
        end
        imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
        alphaVis =  visualizeSoftSegments(initSoftSegments);
        imshow(alphaVis,'Parent',alphaVisAxes, 'InitialMagnification','fit');  
        image  = imread(['../Images/', folderName,'/' fileName(1:end-4) '.png']);
        imshow(image(:,1:end/2,:),'Parent',imageAxes, 'InitialMagnification','fit');  
        
        complete = false;
        while ~complete
            e = waitforbuttonpress;
            if e == 0 % mouse click
                coordinates = get(gca,'CurrentPoint');
                x = round(coordinates(1,1));
                y = round(coordinates(1,2));
                pointAlphas = initSoftSegments(y,x,:);
                [~,idx] = max(pointAlphas);
                if active(idx) == 0
                    fg_matte = fg_matte + initSoftSegments(:,:,idx);
                    imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
                    active(idx) = 1;
                else
                    fg_matte = fg_matte - initSoftSegments(:,:,idx);
                    imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
                    active(idx) = 0;
                end
            else
                c = get(gcf,'CurrentCharacter');
                if c == 's'
                    folder = ['../Files/fga_params/' folderName '/'];
                    save([folder fileName], 'active','-append');
                    folder = ['../Files/fga_maps/' folderName '/'];
                    imwrite(fg_matte, [folder fileName(1:end-4) '.png']);
                else
                    folder = ['../Files/fga_params/' folderName '/'];
                    save([folder fileName], 'active','-append');
                    disp(['Skipped image ' num2str(i) '!']);
                end  
                complete = true;
            end
        end
    end 
    
    function figDelete(~,~)
       save(['../Files/fga_params/' folderName '/currNmbr.mat'], 'i');
       disp('Saving currImNmbr!');
    end
end