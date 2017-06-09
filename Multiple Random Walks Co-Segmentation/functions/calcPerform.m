function [Acu, Err, Pre, Rec, F1] = calcPerform( dec_map, GT_map )

% Input
% dec_map: decision map. It can be binary map or soft decision [0,1] map.
% GT_map: ground truth map.
%
% Output
% peval: performance evalutions. Accuracy / Error rate / Precision / Recall

bsqr = 0.3;

if ~islogical(GT_map)
    error('Ground truth map should be logcal');
end

[R,C] = size(dec_map);
[R1,C1] = size(GT_map);
if R~=R1 || C~=C1
    error('Dimension mismatch');
end



%% performance measure
% TP = sum(sum(dec_map.*GT_map));
% FP = sum(sum(dec_map.*(1-GT_map)));
TP = sum(dec_map(GT_map));
FP = sum(dec_map(~GT_map));
FN = sum(sum(GT_map.*(1-dec_map)));
TN = sum(sum((1-GT_map).*(1-dec_map)));

Acu = (TP+TN)/(R*C);                            % accuracy
Err = (FP+FN)/(R*C);                            % error rate
Pre = TP/(TP+FP+eps);                           % Precision
Rec = TP/(FN+TP+eps);                           % Recall
F1 = (1+bsqr) * (Pre*Rec) / (bsqr*Pre+Rec+eps); % F1 score
    
    
end