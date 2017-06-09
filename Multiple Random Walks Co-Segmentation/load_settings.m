function param = load_settings(  )


addpath('./datasets');
addpath('./functions');
addpath('./library');

run('./library/VLFeat/toolbox/vl_setup');

warning('off', 'stats:kmeans:FailedToConverge');


param.dir.result_root = './results/';
if ~exist(param.dir.result_root, 'dir')
    mkdir(param.dir.result_root)
end


% histogram distance measure
param.hist_dist = 'chisqr';                 % chi-square
% param.hist_dist = 'hisect';                 % histogram intersection

%%%%%%%%%%%%%%%%%%%%%%%
%%% load_database.m
addpath('./library/mexDenseSIFT');
addpath('./library/SLIC_mex');
param.SIFT.cellSize = 3;
param.SIFT.stepSize = 1;

param.SLIC.edge = 20;                               % SLIC parameter, edge sensitivity
param.SLIC.area = 1.5;                              % SLIC parameter, related to the size of superpixels


%%%%%%%%%%%%%%%%%%%%%%%
%%% load_dsim_intra.m
param.BoW_intra.nc = 100;
param.BoW_intra.featureSampling = 20000;
param.BoW_intra.MaxNumIterations = 100;


%%%%%%%%%%%%%%%%%%%%%%%
%%% load_BoW_inter.m
addpath('./library/selfsim/');
addpath('./library/selfsim/supportfunctions/vgg');
param.BoW_inter.nc = 300;
param.BoW_inter.featureSampling = 20000;
param.BoW_inter.MaxNumIterations = 100;


%%%%%%%%%%%%%%%%%%%%%%%
%%% MRW_IS_CS.m
param.disp.nShowImgMax = 4;
param.disp.showPlot = 0;
param.disp.verbose = 1;

param.fw_intra = [0.1 0.2 0.2 0.2 0.3];
param.fw_inter = [0.5 0.2 0.3];

param.sigsqr_intra = 0.05;
param.sigsqr_inter = 0.1;

param.MRW.epsilon = 0.2;
param.MRW.delta = 0.95;
param.MRW.gamma = 0.3;

param.MRW.max_iter = 5e3;
param.MRW.tol = 1e-7;
param.MRW.prior_update = 0;

param.nRndTrial = 20;

param.postprocess = 0;


%%%%%%%%%%%%%%%%%%%%%%%
%%% export_results.m
param.export.input = 1;

param.export.sp_map = 1;
param.export.sp_bnd_col = [1 0 0];

param.export.fac_col.type = 0; % 0: no, 1: hard, 2: transparent coloring
param.export.fac_col.col = [1 0 0]; % red
param.export_fac_col.ratio = 0.2;   % transparent ratio

param.export.bnd_col.type = 1;  % 0: no, 1: boundary coloring
param.export.bnd_col.col = [248 228 0]/255;      % yellow

param.export.tex = 1;
param.export.tex_dir = 'cos_result1';

param.export.inorder = 0;



end

