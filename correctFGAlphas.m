function correctFGAlphas(folderName)
    Fldr = dir([folderName, '_FGA/*.mat']);
    N = size(Fldr,1);
    currNmbr = load([folderName '_FGA/currNmbr.mat']);
    k = currNmbr.i;
     
    figure('DeleteFcn',@figDelete);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    fgAlphaAxes = subplot(1,2,1,'Parent', gcf);
    alphaVisAxes = subplot(1,2,2,'Parent', gcf);
    
    for i=k:N 
        fileName = Fldr(i).name;
        data = load([folderName '_FGA/' fileName]);
        activeSegments = data.activeSegments;
        initSoftSegments = data.initSoftSegments;
        
        [h,w,cnt] = size(initSoftSegments);
        fg_matte = zeros(h,w);
        for k=1:cnt
            if activeSegments(k)==1
                fg_matte = fg_matte + initSoftSegments(:,:,k);
            end
        end
        imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
        alphaVis =  visualizeSoftSegments(initSoftSegments);
        imshow(alphaVis,'Parent',alphaVisAxes, 'InitialMagnification','fit');  
        
        complete = false;
        while ~complete
            e = waitforbuttonpress;
            if e == 0
                coordinates = get(gca,'CurrentPoint');
                x = round(coordinates(1,1));
                y = round(coordinates(1,2));
                pointAlphas = initSoftSegments(y,x,:);
                [~,idx] = max(pointAlphas);
                if activeSegments(idx) == 0
                    fg_matte = fg_matte + initSoftSegments(:,:,idx);
                    imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
                    activeSegments(idx) = 1;
                else
                    fg_matte = fg_matte - initSoftSegments(:,:,idx);
                    imshow(fg_matte,'Parent',fgAlphaAxes, 'InitialMagnification','fit');
                    activeSegments(idx) = 0;
                end
            else
                c = get(gcf,'CurrentCharacter');
                if c == 's'
                    folder = [folderName '_FGA/'];
                    save([folder fileName], 'activeSegments','-append');
                    folder = [folderName '_FGAlphaMaps/'];
                    imwrite(fg_matte, [folder fileName(1:end-4) '.png']);
                else
                    save([folder fileName], 'activeSegments','-append');
                    disp(['Skipped image ' num2str(i) '!']);
                end  
                complete = true;
            end
        end
    end 
    
    function figDelete(~,~)
       save([folderName '_FGA/currNmbr.mat'], 'i');
       disp('Saving currImNmbr!');
    end
end