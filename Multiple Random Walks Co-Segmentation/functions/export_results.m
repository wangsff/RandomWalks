function [ ] = export_results(results, param, selectedResult, selectedMeasure )

if nargin < 4
    selectedMeasure = 1; % 1: Acu, 3: Pre, 5: F1
end
if nargin < 3
    selectedResult = 1:length(results);
end


% load database
load(fullfile(param.dir.result_class,'database.mat'));
nImg = coImg.nImg;                                   % the number of images

% export input images
if param.export.input
    for iIdx = 1:nImg
        [~, fname, ~] = fileparts(coImg.img_in{iIdx});
        imwrite(DB(iIdx).rgb,fullfile(param.dir.result_class,[fname '.png']));
    end
end

% export SLIC super-pixel map
if param.export.sp_map
    nPad = 3;
    nMrg = 1;
    
    for iIdx = 1:nImg
        [~, fname, ~] = fileparts(coImg.img_in{iIdx});
        
        segRGB = DB(iIdx).rgb;
        segMAP = DB(iIdx).sp_map;
        
        bnd_map = segBnd( padarray(segMAP(1+nMrg:end-nMrg,1+nMrg:end-nMrg),nPad*ones(2,1)) );
            
%         diskEnt = strel('disk',2); % radius of 4
%         bnd_map = imdilate(bnd_map,diskEnt);        
        
        bnd_map = bnd_map(1+nPad-nMrg:end-nPad+nMrg, 1+nPad-nMrg:end-nPad+nMrg);
        
        bnd_list = find(bnd_map);
        
        for iRGB = 1:3
            segRGB(bnd_list + (iRGB-1)*DB(iIdx).RC) = param.export.sp_bnd_col(iRGB);
        end
        
        imwrite(segRGB,fullfile(param.dir.result_class,[fname '_SLIC.png']));
    end
end



for mIdx = selectedResult
    
    param.dir.result_export = sprintf('%s/%s', param.dir.result_class, results(mIdx).mname);
    if ~exist(param.dir.result_export, 'dir')
        mkdir(param.dir.result_export);
    end
    
    if param.export.tex
        FP_tex = fopen(fullfile(param.dir.result_export, 'fig.tex'),'w');
    end

    if param.export.inorder
        [~, srt_idx] = sort(results(mIdx).peval(:,selectedMeasure), 'descend');
    end
    
    for sIdx = 1:nImg
        
        if param.export.inorder
            iIdx = srt_idx(sIdx);
        else
            iIdx = sIdx;
        end
        
        % input image
        [~, fname, ~] = fileparts(coImg.img_in{iIdx});
        
        segRGB = DB(iIdx).rgb;
        segMAP = results(mIdx).seg_map{iIdx};
        
        % preprocessing
        diskEnt = strel('disk',2);
        segMAP = imclose(segMAP, diskEnt);
        segMAP = imopen(segMAP, diskEnt);

        % face coloring
        if param.export.fac_col.type ~= 0
            face_list = find(segMAP);

            for iRGB = 1:3
                if param.export.fac_col.type == 1
                    % color replacement
                    segRGB(face_list + (iRGB-1)*DB(iIdx).RC) = param.export.fac_col.col(iRGB);
                elseif param.export.fac_col.type == 2
                    % color augment
                    segRGB(face_list + (iRGB-1)*DB(iIdx).RC) = segRGB(face_list + (iRGB-1)*DB(iIdx).RC) ...
                                                                + param.export_fac_col.ratio*param.export.fac_col.col(iRGB);
                end
            end
        end
        
        % boundary coloring
        if param.export.bnd_col.type            
            nPad = 3;
            nMrg = 1;
        
            bnd_map = segBnd( padarray(segMAP(1+nMrg:end-nMrg,1+nMrg:end-nMrg),nPad*ones(2,1)) );
            
            diskEnt = strel('disk',2); % radius of 4
            bnd_map = imdilate(bnd_map,diskEnt);

            
            bnd_map = bnd_map(1+nPad-nMrg:end-nPad+nMrg, 1+nPad-nMrg:end-nPad+nMrg);
            
            bnd_list = find(bnd_map);

            for iRGB = 1:3
                segRGB(bnd_list + (iRGB-1)*DB(iIdx).RC) = param.export.bnd_col.col(iRGB);
            end            
        end
        
        % write image
        if param.export.inorder
            imwrite(segRGB, fullfile(param.dir.result_export, sprintf('%d_%s.png', sIdx, fname)));
        else
            imwrite(segRGB, fullfile(param.dir.result_export, sprintf('%s.png', fname)));
        end            
    
        % write tex
        if param.export.tex
            % base info
            fprintf(FP_tex, '\\subfigure  {\\includegraphics[height=1.3cm]{./figures/');
            % dir name
            fprintf(FP_tex, [param.export.tex_dir '/' strrep(coImg.cname, ' ', '_') '/']);
            % file name
            if param.export.inorder
                fprintf(FP_tex, '%d_%s', sIdx, fname);
            else
                fprintf(FP_tex, '%s', fname);
            end
            fprintf(FP_tex, '}}\n');
        end

    end
    
    % fclose tex
    if param.export.tex
        fclose(FP_tex);
    end
end





end
