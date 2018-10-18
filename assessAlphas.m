% Go through alphas and extracted foregrounds. Pick the succeful ones. They
% make up the final set of (image, alpha)-pairs for the benchmarking.
function assessAlphas()

    alphaLR = '../Files/alphasLR/';
    imagesHR = '../Files/imagesHR/';
    imagesLR = '../Files/imagesLR/';
    alphaHR = dir('../Files/alphasHR/*.jpg');
    N = size(alphaHR,1);
    disp(N);
    
    f = figure('DeleteFcn',@figDelete);
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    lrAxes = subplot(1,3,1, 'Parent', gcf); %set(lrAxes, 'Tag', num2str(1));
    imAxes = subplot(1,3,2, 'Parent', gcf); %set(imAxes, 'Tag', num2str(3));
    hrAxes = subplot(1,3,3, 'Parent', gcf); %set(hrAxes, 'Tag', num2str(2));
        
    currNmbr = load('currNmbr.mat'); k = currNmbr.i; 
    for i=k:N 
        imName = alphaHR(i).name; imName = [imName(1:end-3), 'png'];
        a_lr = imread([alphaLR imName]);
        image = imread([imagesHR alphaHR(i).name]);
        a_hr = imread([alphaHR(i).folder '/' alphaHR(i).name]);
             
        imshow(a_lr,'Parent',lrAxes, 'InitialMagnification','fit');
        imshow(image,'Parent',imAxes, 'InitialMagnification','fit');
        imshow(a_hr,'Parent',hrAxes, 'InitialMagnification','fit');
        
        e = waitforbuttonpress;
        if e == 0 % mouse click
            
            % Note: Subplot numbering is: [3 2 1]!
            axes = gca;
            allAxes = findobj(f.Children,'Type','axes');
            plot = find(axes==allAxes);
            
            if plot==3
                image = imread([imagesLR imName]);
                imwrite(image, ['../Files/FINAL_LR/' imName(1:end-4) 'i.png']);
                imwrite(a_lr, ['../Files/FINAL_LR/' imName(1:end-4) 'a.png']);
                disp('Stored LR pair.');
            elseif plot==1
                imwrite(image, ['../Files/FINAL_HR/' imName(1:end-4) 'i.jpg']);
                imwrite(a_hr, ['../Files/FINAL_HR/' imName(1:end-4) 'a.jpg']); 
                disp('Stored HR pair.');
            elseif plot==2
                imwrite(image, ['../Files/FINAL_HR/' imName(1:end-4) 'ie.jpg']);
                imwrite(a_hr, ['../Files/FINAL_HR/' imName(1:end-4) 'ae.jpg']);
                disp('Stored FAULTY HR pair.');
            else
                disp('error');
            end
        else
            disp(['Skipped ' num2str(i)]);
        end
    end
    
    function figDelete(~,~)
        save('currNmbr.mat', 'i');
        disp('Saving currImNmbr!');
    end

end
