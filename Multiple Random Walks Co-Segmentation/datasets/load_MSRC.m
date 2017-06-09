function cosegDB = load_MSRC( dataid )

if nargin < 1
    error('No ''dataid''!');
end

base_dir = [fileparts(mfilename('fullpath')) '/MSRC_ObjCategImageDatabase_v2'];

             
switch dataid
    case 1
        cname = 'Cars_front';
        clab = [64 0 128];
        tImg = 6;
        
        rows = 7*ones(1,tImg);
%         cols = [16 17 18 19 20 24];
        cols = [16 17 18 19 20 28];
        
    case 2
        cname = 'Cars_back';
        clab = [64 0 128];
        tImg = 6;
        
        rows = 7*ones(1,tImg);
        cols = [10 11 12 14 15 23];
%         cols = [10 11 12 13 14 15];
        
    case 3
        cname = 'Bike';
        clab = [192 0 128];
        tImg = 30;
        
        rows = 8*ones(1,tImg);
        cols = 1:tImg;
        
    case 4
        cname = 'Cat';
        clab = [0 192 128];
        tImg = 24;
        
        rows = 15*ones(1,tImg);
        cols = 1:tImg;
        
    case 5
        cname = 'Cow';
        clab = [0 0 128];
        tImg = 30;
        
        rows = 5*ones(1,tImg);
        cols = 1:tImg;
        
    case 6
        cname = 'Face';
        clab = [192 128 0];
        tImg = 30;
        
        rows = 6*ones(1,tImg);
        cols = 1:tImg;
        
    case 7
        cname = 'Plane';
        clab = [192 0 0];
        tImg = 30;
        
        rows = 4*ones(1,tImg);
        cols = 1:tImg;
    otherwise
        error('Unknown ''dataid''');
end

img_in = cell(tImg,1);
img_GT = cell(tImg,1);
for k=1:tImg
    img_in{k} = fullfile(base_dir, 'Images', sprintf('%d_%d_s.bmp', rows(k), cols(k)));
    img_GT{k} = fullfile(base_dir, 'GroundTruth', sprintf('%d_%d_s_GT.bmp', rows(k), cols(k)));
end

cosegDB.cname = cname;
cosegDB.clab = clab;
cosegDB.tImg = tImg;
cosegDB.nImg = tImg;
cosegDB.img_in = img_in;
cosegDB.img_GT = img_GT;


end
