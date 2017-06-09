function cosegDB = load_simple( dataid )

if nargin < 1
    error('No ''dataid''!');
end

base_dir = fileparts(mfilename('fullpath'));


switch dataid
    case 1
        cname = 'stone';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'stone1.jpg', 'stone2.jpg'};
        GT_name = {'stone1.bmp', 'stone2.bmp'};
    case 2
        cname = 'banana';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'banana1.bmp', 'banana2.bmp'};
        GT_name = {'banana1.bmp', 'banana2.bmp'};
    case 3
        cname = 'amira';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'amira1.jpg', 'amira2.jpg'};
        GT_name = {'amira1.bmp', 'amira2.bmp'};
    case 4
        cname = 'horse';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'horse1.jpg', 'horse2.jpg'};
        GT_name = {'horse1.bmp', 'horse2.bmp'};
    case 5
        cname = 'llama';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'llama1.jpg', 'llama2.jpg'};
        GT_name = {'llama1.bmp', 'llama2.bmp'};
    case 6
        cname = 'kim';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'kim1.png', 'kim2.png'};
        GT_name = {'kim1.bmp', 'kim2.bmp'};
    case 7
        cname = 'boy';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'boy1.jpg', 'boy2.jpg'};
        GT_name = {'boy1.bmp', 'boy2.bmp'};
    case 8
        cname = 'knut';
        clab = [255 255 255];
        tImg = 2;
        img_name = {'bear1.jpg', 'bear2.jpg'};
        GT_name = {'bear1.bmp', 'bear2.bmp'};
    case 9
        cname = 'dog';
        clab = [255 255 255];
        tImg = 4;
        img_name = {'tinbie1.jpg', 'tinbie2.jpg', 'tinbie3.jpg', 'tinbie4.jpg'};
        GT_name = {'tinbie1.bmp', 'tinbie2.bmp', 'tinbie3.bmp', 'tinbie4.bmp'};
    case 10
        cname = 'genome';
        clab = [255 255 255];
        tImg = 4;
        img_name = {'genome1.jpg', 'genome2.jpg', 'genome3.jpg', 'genome4.jpg'};
        GT_name = {'genome1.bmp', 'genome2.bmp', 'genome3.bmp', 'genome4.bmp'};
    otherwise
        error('Unknown ''dataid''');
end

img_in = cell(tImg,1);
img_GT = cell(tImg,1);

if dataid <= 2
    for k=1:tImg
        img_in{k} = fullfile(base_dir, 'GrabCut', 'data_GT', img_name{k});
        img_GT{k} = fullfile(base_dir, 'GrabCut', 'boundary_GT', GT_name{k});       
    end
else
    for k=1:tImg
        img_in{k} = fullfile(base_dir, 'fromInternet', img_name{k});
        img_GT{k} = fullfile(base_dir, 'fromInternet', GT_name{k});       
    end
end

cosegDB.cname = cname;
cosegDB.clab = clab;
cosegDB.tImg = tImg;
cosegDB.nImg = tImg;
cosegDB.img_in = img_in;
cosegDB.img_GT = img_GT;

end

