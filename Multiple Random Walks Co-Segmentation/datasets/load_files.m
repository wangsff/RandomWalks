function out_list = load_files( in_path, varargin )

% in_path     : 1 x M cell
% out_list    : output file list structure. if it is given, data will be
%               updated. [setID, testID]
% ext_filter  : N x 1 cell
%
% 

%% input parser
p = inputParser;

default_ext_filters = {};
default_out_list = struct('path',{}, 'name_main',{}, 'name_full',{}, 'ext',{});

addRequired(p, 'in_path', @iscell)
addOptional(p, 'ext_filter', default_ext_filters, @iscell);
addOptional(p, 'out_list', default_out_list, @isstruct);

parse(p, in_path, varargin{:});

% pass variable
ext_filter = p.Results.ext_filter;
out_list = p.Results.out_list;


%% input check
[tmp, nPath] = size(in_path);
if tmp ~= 1
    error('in_path should be 1 x M cell');
end



[setNum, ~] = size(out_list);

for idx_path = 1:nPath
    curr_path = in_path{idx_path};
    
    dir_list = dir(curr_path);
    
    idx_file = 1;
    for k=1:length(dir_list)
        if ~dir_list(k).isdir
            
            [~, name, ext] = fileparts(dir_list(k).name);
            
            splitEXT = strsplit(ext, '.');
            ext = splitEXT{end};
            
            if isempty(ext_filter)
                out_list(setNum+idx_path, idx_file).path = curr_path;
                out_list(setNum+idx_path, idx_file).name_main = name;
                out_list(setNum+idx_path, idx_file).name_full = dir_list(k).name;
                out_list(setNum+idx_path, idx_file).ext = ext;
                
                idx_file = idx_file + 1;
            elseif strcmp(ext, ext_filter)
                out_list(setNum+idx_path, idx_file).path = curr_path;
                out_list(setNum+idx_path, idx_file).name_main = name;
                out_list(setNum+idx_path, idx_file).name_full = dir_list(k).name;
                out_list(setNum+idx_path, idx_file).ext = ext;
                
                idx_file = idx_file + 1;
            end
            
            
        end
    end
end




end

