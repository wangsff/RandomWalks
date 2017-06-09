
clc;
close all;
clear all;

param = load_settings;

setid = 4;      % iCoseg
dataid = 16;    % Taj Mahal


coImgAll = load_datasets(setid,dataid);                                    % load co-segmentation data

if coImgAll.nImg == coImgAll.tImg
    trylist = 1;
else
    trylist = 1:param.nRndTrial;
end


for tryid = trylist

param.dir.result_class = sprintf('%s%d_%02d_%s_%02d/', param.dir.result_root, setid, dataid, coImgAll.cname, tryid);
if ~exist(param.dir.result_class, 'dir')
    mkdir(param.dir.result_class);
end

% display header
fprintf('(%d, %02d) / %s / %d of %d pics / trial:%d\n', ...
    setid, dataid, coImgAll.cname, coImgAll.nImg, coImgAll.tImg, tryid);

% main algorithm
[results, eval] = MRW_IS_CS(coImgAll, param);

% save results
save(fullfile(param.dir.result_class, 'results.mat'), 'results', 'eval');

% export images from 'results.mat'
export_results(results,param);



end


msgbox(sprintf('%s done', mfilename));