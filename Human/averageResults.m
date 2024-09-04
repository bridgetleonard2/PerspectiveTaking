% Run in local directory

left_right = get_mean_std('data/raw/left_right');
nine_six = get_mean_std('data/raw/9_6');
M_W = get_mean_std('data/raw/M_W');

save('data/group/leftright.mat', 'left_right')
save('data/group/ninesix.mat', 'nine_six')
save('data/group/MW.mat', 'M_W')

%% functions
function group_data = get_mean_std(path)
    % Extract data files from folder
    file_list = dir(path);
    file_list = file_list(~[file_list.isdir]);
    num_subj = length(file_list);

    % Create empty matrices to store results
    all_data = zeros(num_subj, 128); % To combine all subj data over all trials (128)

    % and a matrix for subject-level means
    orientations = [0, 45, 90, 135, 180, 225, 270, 315];
    subj_rt = zeros(num_subj, length(orientations));
    subj_orientations = zeros(num_subj, 128); % some subj ran different runs

    for subj = 1:num_subj
        % Load subject data
        file_name = file_list(subj).name;
        full_file_path = fullfile(path, file_name);

        file_data = load(full_file_path);

        % Get data
        responses = file_data.responses;
        trialOrder = file_data.trialOrder; % same for all participants
        reactionTimes = responses(2,:);

        % Add data to group for standard error calc
        all_data(subj, :) = reactionTimes;

        % calculate mean
        trial_orientations = orientations(trialOrder);
        subj_orientations(subj, :) = trial_orientations;
        for orient = 1:length(orientations)
            indices = (trial_orientations == orientations(orient));
            subj_rt(subj,orient) = nanmean(reactionTimes(indices));
        end
    end

    % Calculate standard deviation
    subj_error = zeros(3, length(orientations));
    group_data = zeros(2, length(orientations));
    group_data(1, :) = mean(subj_rt);

    for i = 1:length(orientations)
        for subj = 1:num_subj
            indices = (subj_orientations(subj, :) == orientations(i));
            orientation_data = all_data(:, indices);
            subj_error(subj, i) = nanstd(orientation_data(subj, :)) ./ sqrt(128);
        end

        group_data(2, i) = nanstd(orientation_data(:)) / sqrt(128);
    end
end