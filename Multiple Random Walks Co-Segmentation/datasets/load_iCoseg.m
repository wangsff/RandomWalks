function cosegDB = load_iCoseg( dataid )

if nargin < 1
    error('No ''dataid''!');
end
if dataid > 16
    error('iCoseg contains 16 sets of images');
end

base_dir = [fileparts(mfilename('fullpath')) '/CMU_Cornell_iCoseg_dataset/dataset_public'];


cinfo = struct('cname', {}, ... class name
               'cpath', {}, ... class path
               'tImg', {}, ... total number of images
               'nImg', {}, ... number of selected images
               'selectedImg', {} ... index of selected images
               );

cinfo(1).cname = 'Alaskan Bear';
cinfo(1).cpath = '002 Alaskan Brown Bear-Eukaryote museums Milwaukee Zoo 2006-cmlburnett';
cinfo(1).tImg = 19;
cinfo(1).nImg = 9;

cinfo(2).cname = 'Balloon';
cinfo(2).cpath = '041 Hot Balloons-Skybird Flight 9.27.08-Tracy Sasser';
cinfo(2).tImg = 24;
cinfo(2).nImg = 8;   

cinfo(3).cname = 'Baseball';
cinfo(3).cpath = '006 Red Sox Players - Red Sox Yankees Game-JB Imaging';
cinfo(3).tImg = 25;
cinfo(3).nImg = 8;

cinfo(4).cname = 'Bear';
cinfo(4).cpath = 'brown_bear';
cinfo(4).tImg = 5;
cinfo(4).nImg = 5;

cinfo(5).cname = 'Elephant';
cinfo(5).cpath = '021 Elephants-safari June 2008-timd2000';
cinfo(5).tImg = 15;
cinfo(5).nImg = 7;

cinfo(6).cname = 'Ferrari';
cinfo(6).cpath = '015 Ferrari 599 GTB Fiorano-599-auTomoTiVe FreAk !';
cinfo(6).tImg = 11;
cinfo(6).nImg = 11;

cinfo(7).cname = 'Gymnastics';
cinfo(7).cpath = '036 Gymnastics-3';
cinfo(7).tImg = 6;
cinfo(7).nImg = 6;

cinfo(8).cname = 'Kite';
cinfo(8).cpath = '032 Kite-Brighton kite Festival-jadepike4';
cinfo(8).tImg = 18;
cinfo(8).nImg = 8;

cinfo(9).cname = 'Kite panda';
cinfo(9).cpath = '034 Kite-Margate Kite Festival 08-only lines';
cinfo(9).tImg = 7;
cinfo(9).nImg = 7;

cinfo(10).cname = 'Liverpool';
cinfo(10).cpath = '014 Liverpool FC Players-Liverpool FC-phes999';
cinfo(10).tImg = 33;
cinfo(10).nImg = 9;

cinfo(11).cname = 'Panda';
cinfo(11).cpath = '023 Pandas-Tai-Land 6708-TAIwiffic';
cinfo(11).tImg = 25;
cinfo(11).nImg = 8;

cinfo(12).cname = 'Skating';
cinfo(12).cpath = '037 Skating-Skating-Rich Moffitt';
cinfo(12).tImg = 11;
cinfo(12).nImg = 7;

cinfo(13).cname = 'Statue';
cinfo(13).cpath = '042 Statue of Liberty-Liberty Enlightening the World (Groups)-EricaJoy';
cinfo(13).tImg = 41;
cinfo(13).nImg = 10;

cinfo(14).cname = 'Stonehenge';
cinfo(14).cpath = '009 Stonehenge-Stongehenge-rjt208';
cinfo(14).tImg = 5;
cinfo(14).nImg = 5;

cinfo(15).cname = 'Stonehenge 2';
cinfo(15).cpath = '012 Stonehenge-Salisbury Cathedral and Stonehenge-Sou''wester';
cinfo(15).tImg = 18;
cinfo(15).nImg = 9;

cinfo(16).cname = 'Taj Mahal';
cinfo(16).cpath = '017 Agra Taj Mahal-Taj Mahal-LeszekZadlo';
cinfo(16).tImg = 5;
cinfo(16).nImg = 5;


filelist = load_files({fullfile(base_dir, 'images', cinfo(dataid).cpath)}, 'ext_filter', {'jpg'});
if length(filelist)~=cinfo(dataid).tImg
    error('Not enough files in the ''%s'' folder', cinfo(dataid).cname);
end

img_in = cell(cinfo(dataid).tImg,1);
img_GT = cell(cinfo(dataid).tImg,1);

for k=1:cinfo(dataid).tImg
    img_in{k} = fullfile(base_dir, 'images', cinfo(dataid).cpath, filelist(k).name_full);
    img_GT{k} = fullfile(base_dir, 'ground_truth', cinfo(dataid).cpath, [filelist(k).name_main '.png']);
end


cosegDB.cname = cinfo(dataid).cname;
cosegDB.clab = 1;
cosegDB.tImg = cinfo(dataid).tImg;
cosegDB.nImg = cinfo(dataid).nImg;
cosegDB.img_in = img_in;
cosegDB.img_GT = img_GT;

end

