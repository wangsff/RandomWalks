function cosegDB = load_datasets( setid, dataid ) 

base_dir = fileparts(mfilename('fullpath'));

% load data
if nargin < 2
    error('No dataid!');
end
if nargin < 1
    error('No setid!');
end


cosegDB = struct('cname', [], ... classname
                 'clab', [], ... ground-truth label information
                 'tImg', [], ... total number of images
                 'nImg', [], ... the number of images
                 'img_in', [], ... input image location
                 'img_GT', [] ... ground-truth image location
                 );

switch setid
    case 1
        % simple dataset, i.e. stone, banana, ...
        cosegDB = load_simple( dataid );
        
    case 2
        if dataid ~= 1
            error('Unknown ''dataid''');
        end
        % Weizman horse
        cname = 'Weizmen horse';
        clab = [255 255 255];
        tImg = 328;
        nImg = 30;
        
        img_in = cell(tImg,1);
        img_GT = cell(tImg,1);
        for k=1:tImg
            img_in{k} = fullfile(base_dir, 'weizmann_horse_db', 'rgb', sprintf('horse%03d.jpg', k));
            img_GT{k} = fullfile(base_dir, 'weizmann_horse_db', 'figure_ground', sprintf('horse%03d.jpg', k));
        end

        cosegDB.cname = cname;
        cosegDB.clab = clab;
        cosegDB.tImg = tImg;
        cosegDB.nImg = nImg;
        cosegDB.img_in = img_in;
        cosegDB.img_GT = img_GT;
        
    case 3
        % MSRC dataset
        cosegDB = load_MSRC( dataid );
        
    case 4
        % iCoseg dataset
        cosegDB = load_iCoseg( dataid );
        
    otherwise
        error('Unknown ''setid''');
end


end
