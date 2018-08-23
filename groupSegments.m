
% A simple grouping of soft segments w.r.t. their semantic features
% as described in Section 3.4.

function groupedSegments = groupSegments(segments, features, segmCnt, fg)
    if ~exist('segmCnt', 'var') || isempty(segmCnt)
        segmCnt = 5;
    end
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
    for i = 1 : segmCnt
        segment = sum(segments(:,:,ids==i), 3);
        segmentMask = round(segment);
        intersection = segmentMask(idxs);
        if sum(intersection) > 0
            groupedSegments(:,:,1) = groupedSegments(:,:,1) + segment;       
        else 
            groupedSegments(:,:,j) = segment;
            j = j+1;
        end
    end 
end