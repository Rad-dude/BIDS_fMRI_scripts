function [group, opt, BIDS] = getData(opt)
% The following structure will be the base that the function will use to run
% the preprocessing pipeline according to the BIDS Structure

fprintf(1,'FOR TASK: %s\n', opt.taskName)

% The directory where the derivatives are located
derivativesDir = opt.derivativesDir;

% we let SPM figure out what is in this BIDS data set
BIDS = spm_BIDS(derivativesDir);

% get IDs of all subjects
subjects = spm_BIDS(BIDS, 'subjects');

% get metadata for bold runs for that task
% we take those from the first run of the first subject assuming it can
% apply to all others.
metadata = spm_BIDS(BIDS, 'metadata', ...
    'task', opt.taskName, ...
    'sub', subjects{1}, ...
    'type', 'bold');
if iscell(metadata)
    opt.metadata = metadata{1};
else
    opt.metadata = metadata;
end

%% Add the different groups in the experiment
for iGroup = 1:numel(opt.groups) % for each group
    group(iGroup).name = opt.groups{iGroup}; %#ok<*AGROW>                            % NAME OF THE GROUP 

    % we figure out which subjects to take if not specified take all subjects
    if isfield(opt,'subjects') && ~isempty(opt.subjects{iGroup})
        idx = opt.subjects{iGroup};
        
        % find the subjects that belong to that group
        groupSubIdx = find(~cellfun('isempty',strfind(subjects,group(iGroup).name))) ; % compare the subjects with the group name 
        groupSubs = subjects(groupSubIdx) ;                                  % Get the index of the subjects corresponding to this group
        group(iGroup).subNumber = groupSubs(idx);                            % SUBJECT ID .. con01 , con02 , etc.
        %group(iGroup).subNumber = [group(iGroup).name, subjects(idx)];      % SUBJECT ID .. con01 , con02 , etc. OLD LINE
        group(iGroup).numSub = length(group(iGroup).subNumber) ;             % Number of subjects in the group
        
    else
        % in case no group was specified (e.g. sub-01) we need a way to still
        % get the subjects ID
        if strcmp(group(iGroup).name, '')
            idx = 1:size(subjects,2);
        else
            idx = strfind(subjects, group(iGroup).name);
            idx = find(~cellfun('isempty', idx));
        end      
        group(iGroup).subNumber = subjects(idx);                            % SUBJECT ID .. con01 , con02 , etc.
        group(iGroup).numSub = length(group(iGroup).subNumber) ;            % Number of subjects in the group
        
    end
    
    
    fprintf(1,'WILL WORK ON SUBJECTS\n')
    disp(group(iGroup).subNumber)
end


end
