function BIDS_copyRawFolder(opt, deleteZippedNii)
% This function will copy the subject's folders from the "raw" folder to the
% "derivatives" folder, and will copy the dataset description and task json files
% to the derivatives directory.
% Then it will search the derivatives directory for any zipped nii.gz image
% and uncompress it to .nii images.
%
% INPUT:
%
% opt - options structure defined by the getOption function. If no inout is given
% this function will attempt to load a opt.mat file in the same directory
% to try to get some options
%
% deleteZippedNii - true or false and will delete original zipped files
% after copying and unzipping


%% input variables default values
if nargin<2            % if second argument isn't specified
   deleteZippedNii = 1;  % delete the original zipped nii.gz
end

% if input has no opt, load the opt.mat file
if nargin < 1
    load('opt.mat')
    fprintf('opt.mat file loaded \n\n')
end

%% All tasks in this experiment
% raw directory and derivatives directory
rawDir = opt.dataDir;
derivativeDir = fullfile(rawDir, '..', 'derivatives', 'SPM12_CPPL');

% make derivatives folder if it doesnt exist
if ~exist(derivativeDir, 'dir')
    mkdir(derivativeDir);
    fprintf('derivatives directory created: %s \n', derivativeDir)
else
    fprintf('derivatives directory already exists. \n')
end

% copy TSV and JSON file from raw folder if it doesnt exist
copyfile(fullfile(rawDir, '*.json'), derivativeDir);
fprintf(' json files copied to derivatives directory \n');

copyfile(fullfile(rawDir, '*.tsv'), derivativeDir);
fprintf(' tsv files copied to derivatives directory \n');


%% Loop through the groups, subjects, sessions

group = getData(opt, rawDir);


for iGroup= 1:length(group)       % For each group
    groupName = group(iGroup).name ;    % Get the group name
    
    for iSub = 1:group(iGroup).numSub  % For each Subject in the group
        
        subNumber = group(iGroup).subNumber{iSub} ; % Get the subject ID
        
        % the folder containing the subjects data
        subFolder = ['sub-', subNumber ];
        
        % copy the whole subject's folder
        copyfile(fullfile(rawDir, subFolder),...
            fullfile(derivativeDir, subFolder));
        
        fprintf('folder copied: %s \n', subFolder)
        
    end
end


%% search for nifti files in a compressed nii.gz format
zippedNiifiles = spm_select('FPListRec', derivativeDir, '^.*.nii.gz$');

for iFile = 1:size(zippedNiifiles,1)
    
    file = deblank(zippedNiifiles(iFile,:));
    
    n = load_untouch_nii(file);  % load the nifti image
    save_untouch_nii(n, file(1:end-4)); % Save the functional data as unzipped nii
    fprintf('unzipped: %s \n', file)
    
    if deleteZippedNii==1
        delete(file)  % delete original zipped file
    end
end

end

