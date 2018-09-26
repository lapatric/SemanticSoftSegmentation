I = load('results.mat');
results = I.results;
N = size(results,1);
for i=1:N
    disp(i);
    if ~isempty(results{i}) 
        imName = results{i,1};
        segments = results{i,2};
        active = results{i,3};
        folder = '../../Files/fga_params/partsmfeat/';
        save([folder imName '.mat'], 'segments', 'active');
    end
end
% I = loadc('results.mat');
% I = I.results;
% 
% segments = I{153,2};
% active = I{153,3};
% N = size(active);
% fg_mask = zeros(size(segments(:,:,1)));
% 
% for i=1:N
%     if active(i) ~= 0
%         fg_mask = fg_mask + segments(:,:,i);
%     end
% end
% 
% imshow(fg_mask);