clear 
clc

%% Run batches
opt = getOption();

% the cdirectory with this script becomes the current directory
WD = pwd;

% we add all the subfunctions that are in the sub directories
addpath(genpath(WD))

% In case some toolboxes need to be added the matlab path, specify and uncomment
% in the lines below
% toolbox_path = '';
% addpath(fullfile(toolbox_path)

checkDependencies();

% copy raw folder into derivatives folder
BIDS_copyRawFolder(opt, 1)

% preprocessing
BIDS_STC(opt);
BIDS_SpatialPrepro(opt);
BIDS_Smoothing(6, opt);

% subject level Univariate
BIDS_FFX(1, 6, opt);
BIDS_FFX(2, 6, opt);

% group level univariate
BIDS_RFX(1, 6, 6)
BIDS_RFX(2, 6, 6)

BIDS_Results(6, 6, opt, 0)

% subject level multivariate
isMVPA=1;
BIDS_FFX(1, 6, opt, isMVPA);
BIDS_FFX(2, 6, opt, isMVPA);
make4Dmaps(6,opt)


