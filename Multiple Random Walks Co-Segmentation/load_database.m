function [ coImg, DB, param ] = load_database(coImgAll, param, nImg)


if ~exist(fullfile(param.dir.result_class, 'database.mat'), 'file')
    
    % select images by random permutation
    coImg.cname = coImgAll.cname;
    coImg.clab = coImgAll.clab;
    coImg.tImg = coImgAll.tImg;
    if nargin < 3
        coImg.nImg = coImgAll.nImg;
        nImg = coImg.nImg;
    else
        coImg.nImg = nImg;
    end
    
    selectedImg = sort(randperm(coImg.tImg, coImg.nImg));    
    coImg.img_in = coImgAll.img_in(selectedImg);
    if isfield(coImgAll,'img_GT')
        coImg.img_GT = coImgAll.img_GT(selectedImg);
    end
    
    
    % features
    DB = struct('R',{}, ... the number of rows = height
                'C',{}, ... the number of cols = width
                'RC', {}, ... image size
                'rgb', {}, ... RGB color image
                'lab', {}, ... LAB color image
                'gray', {}, ... gray image
                'gx', {}, ... gradient component for horizontal direction
                'gy', {}, ... gradient component for vertical direction
                'sift', {}, ... dense SIFT feature
                'sp_map', {}, ... superpixel map
                'sp_idx', {}, ... superpixel index
                'nsp', {}, ... number of superpixels
                'ssp', {}, ... size of superpixels
                'sp_center', {}, ... superpixel center mass
                'sp_rgb_mean', {}, ... superpixel RGB mean
                'sp_lab_mean', {}, ... superpixel CIE LAB mean
                'GT_map', {} ... ground-truth map
                );
    
    % evaluate elapsed time
    eval.time = [];
    
    % precompute features
    for iIdx =1:nImg
        
        timeImg = [];
        tic;
        %% input image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        img_path = coImg.img_in{iIdx};
        [~, fname, ~] = fileparts(img_path);

        img_rgb = im2double(imread(img_path));
        [R,C,~] = size(img_rgb);        
        
        timeImg = [timeImg toc];
        
        DB(iIdx).R = R;
        DB(iIdx).C = C;
        DB(iIdx).RC = R*C;
        
        tic;
        %% pixel level feature: RGB color
        DB(iIdx).rgb = img_rgb;        
        
        %% pixel level feature: LAB color
        DB(iIdx).lab = colorspace('Lab<-', img_rgb);
        
        tic;
        %% pixel level feature: Gray and gradient image
        img_gray = rgb2gray(img_rgb);
        [gx, gy] = calcGrad(img_gray);
        
        timeImg = [timeImg toc];
        
        DB(iIdx).gray = img_gray;
        DB(iIdx).gx = gx;
        DB(iIdx).gy = gy;
        
        tic;
        %% pixel level feature: denseSIFT
        DB(iIdx).sift = mexDenseSIFT(img_rgb, param.SIFT.cellSize, param.SIFT.stepSize);
            
        timeImg = [timeImg toc];
        
        tic;
        %% input superpixel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        param.SLIC.nsp = round(sqrt(DB(iIdx).RC)/param.SLIC.area);
        
        [sp_map, nv] = slicmex(im2uint8(DB(iIdx).rgb),param.SLIC.nsp,param.SLIC.edge);
        sp_map = double(sp_map + 1);
        nv = double(nv);
        
        timeImg = [timeImg toc];
        
        DB(iIdx).sp_map = sp_map;        
        DB(iIdx).nsp = nv;
                
        
        tic;
        %% superpixel level features %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % basic info        
        sp_idx = cell(nv,1);
        ssp = zeros(nv,1);
        sp_center = zeros(nv,2);
        for i=1:nv
            sp_idx{i} = find(sp_map==i);
            ssp(i) = length(sp_idx{i});
            
            [r, c, ~] = find(sp_map == i);
            sp_center(i,:) = mean([r, c]);
        end
        
        % temp reshape
        elong_rgb = reshape(img_rgb, R*C, 3);
        elong_lab = reshape(DB(iIdx).lab, R*C, 3);
        
        % sp_rgb_mean        
        sp_rgb_mean = zeros(nv,3);        
        for i=1:nv
            sp_rgb_mean(i,:) = mean(elong_rgb(sp_idx{i},:));
        end
        
        % sp_lab_mean
        sp_lab_mean = zeros(nv,3); 
        for i=1:nv
            sp_lab_mean(i,:) = mean(elong_lab(sp_idx{i},:));
        end
        
        timeImg = [timeImg toc];
        
        
        DB(iIdx).sp_idx = sp_idx;
        DB(iIdx).ssp = ssp;
        DB(iIdx).sp_center = sp_center;        
                
        DB(iIdx).sp_rgb_mean = sp_rgb_mean;
        DB(iIdx).sp_lab_mean = sp_lab_mean;
        
        
        
        tic;
        %% GT map %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % GT image
        if isfield(coImg, 'img_GT')
            GT_img_path = coImg.img_GT{iIdx};
            GT_img = imread(GT_img_path);
            [R,C,~] = size(GT_img);

            if R~=DB(iIdx).R || C~=DB(iIdx).C
                GT_img = imresize(GT_img, [DB(iIdx).R, DB(iIdx).C]);
            end

            % GT map
            if length(size(GT_img)) == 3
                GT_map = (GT_img(:,:,1) == coImg.clab(1)) & (GT_img(:,:,2) == coImg.clab(2)) & (GT_img(:,:,3) == coImg.clab(3));
            else
                GT_map = GT_img>=mean(GT_img(:));
            end

            timeImg = [timeImg toc];

            DB(iIdx).GT_map = GT_map;
        end
        
        
        eval.time = [eval.time; timeImg];
        
    end
                
    
    save(fullfile(param.dir.result_class, 'database.mat'), 'coImg', 'DB', 'eval');
    if param.disp.verbose
        fprintf('image DB is constructed and saved!\n');
    end
else
    load(fullfile(param.dir.result_class, 'database.mat'));
    if param.disp.verbose
        fprintf('image DB is loaded!\n');
    end
end

