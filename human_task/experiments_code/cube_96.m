%% Scanner timing parameters
% TR = 1
% number of scans = 160
% total time = 396 sec / 6 min 36 sec
% left is green (#3), red is right (#4)

%% Clean up workspace
clear; close all; clc;
experimentName = '9_6';
sessName = 'rotPps'; 
%% switches
eyeTrack = 0;       % 0 means "NO", 1 means "YES"
debugMode = 1;      % 0 means "NO", 1 means "YES" (debug uses a shorter sequence of trials)
mock = 0;           % if in mock scanner (change keyboard codes and screen number)
%%
Screen('Preference', 'SkipSyncTests', 1); % Skip sync tests for this example only
Screen('Preference', 'VisualDebugLevel', 0); % Remove red screen
%% experimental run information
subjectCode = input('subjectCode = (e.g., B401): ','s');
runNumber = input('runNumber = (1:4): ');
HideCursor;
%% Eyetracking options
% Filename for edfs has to be a smaller filename 1-8 characters
edfFile = [subjectCode 'atnC' int2str(runNumber)]; % 3+2+1

%Eye tracker initialization
if eyeTrack == 1 % if we're using the eyetracker, bring up calibration screen
    dummymode = 0;
    screenNumber = 1;
    [window, wRect]=Screen('OpenWindow', screenNumber,0,[0 0 1920 1080]);
    eyelink_init2
end
%% viewing parameters (stored one directory up)
if debugMode == 1
    currentDir = pwd;
    cd ('..')
    displayParameters % execute .m file common to all the experiments
    cd (currentDir)
else
    displayParameters % execute .m file common to all the experiments
end
%% Define the response keys
KbName('UnifyKeyNames');
% Define the 't' keypress
tKey = KbName('t');
escapeKey = KbName('ESCAPE');

leftKey = 37;
rightKey = 39;   
%% load mseq trialOrders
% trialOrder are numbers 1:8 that define different trial types
filename = sprintf('trials%d.txt', runNumber);
trialOrder = load(filename);

% if debugMode == 1
%     values = 1:8;
%     repeated_values = repmat(values, 1, 4);
%     trialOrder = repeated_values(randperm(length(repeated_values)));
% end

%%
nTrials = length(trialOrder);

contrasts = [0.0 0.06 0.50 ]; % 0 = blank trials
stimulusDuration = 2; % Duration of motion stimuli, in sec

orientations = [0, 45, 90, 135, 180, 225, 270, 315];

%%
% Setup PTB with some default values
PsychDefaultSetup(2);
% Prepare the imaging pipeline configuration
PsychImaging('PrepareConfiguration');
% Add the gamma correction task
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
%screenNumber = max(Screen('Screens')); % Select the external screen if it exists, otherwise select the main screen
screenNumber = 0;

[window, rect] = PsychImaging('OpenWindow', screenNumber, .5); % Open a new window with a gray background
PsychColorCorrection('SetEncodingGamma', window, 1/display.gamma);

[xCenter, yCenter] = RectCenter(rect); % Get the center coordinates of the window
%ifi = Screen('GetFlipInterval', window); % Get the inter-frame interval (duration of a single frame)
ifi = 1/display.screenRefreshRate;

% % Define the positions of the images
imageRect = [0 0 display.screenResolution(1)/2 display.screenResolution(2)/2];

% Generate the cue textures
d1 = 0.6; %diameterofoutercircle(degrees)
d2 = 0.2; %diameterofinnercircle(degrees)
cueSize = d2*ppd; %5;  % Size of the cue
cueBitmap = makeBullseyeCue(d1, d2, ppd); % makeFixation(cueSize);
cueTexture = Screen('MakeTexture', window, cueBitmap);

%% Timing details
% Calculate the number of frames for each trial
nFramesStim = round(stimulusDuration/ifi);

%% Trigger the experiment
% Set the screen to gray
Screen('FillRect', window, 0.5);

% Create the cue bitmap
waitCueBitmap = makeBullseyeCue(d1, d2, ppd); % makeFixation(cueSize);

% Convert the bitmap into a texture
waitCueTexture = Screen('MakeTexture', window, waitCueBitmap);

% Draw the cue in the center of the screen
Screen('DrawTexture', window, waitCueTexture, [], CenterRectOnPointd([0 0 cueSize cueSize], xCenter, yCenter));

% Define the text strings for the instructions
instr0 = 'HOLD STILL';
instr1 = 'Waiting for the scanner to start.';
instr2 = 'For the following images, based on the cue type:';
instr3 = 'Respond with LEFT or RIGHT to indicate if the cube is to the LEFT or RIGHT from the PERSPECTIVE OF THE PERSON';
instr4 = 'Respond with INFRONT or BEHIND to indicate if the cube is INFRONT or BEHIND the PERSON';
instr5 = 'Respond as quickly and accurately as possible.';

% Define the coordinates for the instructions
instrYPos = yCenter - 150;  % Slightly above the center

% Draw the instructions on the screen
Screen('TextSize', window, 20);
Screen('DrawText', window, instr0, xCenter-400, instrYPos-60, [1 1 1]);  % Adjust the x position for the width of your text
Screen('DrawText', window, instr1, xCenter-400, instrYPos-20, [1 1 1]);  % Adjust the x position for the width of your text
Screen('DrawText', window, instr2, xCenter-400, instrYPos+20, [1 1 1]);  % Adjust the x position for the width of your text
Screen('DrawText', window, instr3, xCenter-400, instrYPos+45, [1 1 1]);  % Adjust the x position for the width of your text
Screen('DrawText', window, instr4, xCenter-400, instrYPos+70, [1 1 1]);  % Adjust the x position for the width of your text
Screen('DrawText', window, instr5, xCenter-400, instrYPos+95, [1 1 1]);  % Adjust the x position for the width of your text

% Display the gray screen with the cue and instructions
Screen('Flip', window);
WaitSecs(3);

Screen('DrawTexture', window, waitCueTexture, [], CenterRectOnPointd([0 0 cueSize cueSize], xCenter, yCenter));
Screen('Flip', window);

% Wait for 't' key press to start
startKey = KbName('t');  % Get the code for the 't' key
pressed = 0;

while ~pressed
    [pressed, ~, keyCode] = KbCheck;
    if pressed
        if keyCode(startKey)
            break;  % Exit the loop if 't' is pressed
        elseif keyCode(escapeKey)
            disp('We are interrupting early.');
            Screen('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
            Screen('Flip',window);
            pause(0.3);
            Screen('Closeall');
            sca; ShowCursor;  % Close the screen
            error('Experiment terminated by user');  % Throw an error
            return; 
        else
            pressed = 0;  % Reset the pressed flag if another key was pressed
        end
    end
end

% Don't forget to close the texture when it's not needed anymore
Screen('Close', waitCueTexture);

%% Load the img bitmaps
% load cues

stim_dir = '..\..\KW_blender_temp\9_6';

level_files = dir(stim_dir);
level_files = {level_files(~[level_files.isdir]).name};
cube_level = level_files(1, 1:8);
sphere_level = level_files(1, 9:16);

level_textures = zeros(length(cube_level), 2);
for i = 1:length(cube_level)
    item = cube_level{i}; % Use {} for cell array access
    imageMatrix = imread(fullfile(stim_dir, item));
    textureID = Screen('MakeTexture', window, imageMatrix);
    if textureID == 0
        error('Failed to create texture for %s', item);
    end
    level_textures(i,1) = textureID;
end

for i = 1:length(sphere_level)
    item = sphere_level{i}; % Use {} for cell array access
    imageMatrix = imread(fullfile(stim_dir, item));
    textureID = Screen('MakeTexture', window, imageMatrix);
    if textureID == 0
        error('Failed to create texture for %s', item);
    end
    level_textures(i,2) = textureID;
end

% matrix will be 2x8
% cube first col, sphere second
% row order = 0, 135, 180, 225, 270, 315, 45, 90:
newRowOrder = [1, 7, 8, 2, 3, 4, 5, 6];
level_textures = level_textures(newRowOrder, :);
%% start the experiment

% trialOrder are numbers 1:8 that define different trial types
% 1, 2, 3, 4, 5, 6 are orientations
% 7, 8 are null

KbQueueCreate;
KbQueueStart;

responses = NaN(2, nTrials); % Initialize a 2xN array filled with NaNs
trialEnds = 3:3:3*nTrials;
experimentStartTime = GetSecs();  % start timer for block
for trial = 1:nTrials
    %\eye
    et_message = ['Trial_' num2str(trial)];
    if eyeTrack == 1
    Eyelink('Message', et_message);
    end
    %/eye
    trialStartFrameTime = GetSecs;  % Timestamp before starting the frame loop
    trialOnsets(trial) = trialStartFrameTime - experimentStartTime;
    trialType = trialOrder(trial);

    % Present the stimuli
    cube_sphere = randsample(2, 1); % 1 is cube, 2 is sphere
    startTime = GetSecs();
    for frame = 1:nFramesStim
        bmp_texture = level_textures(trialType, cube_sphere);
        Screen('DrawTexture', window, bmp_texture, [], CenterRectOnPointd(imageRect, xCenter, yCenter));

        % Flip the screen to show the textures drawn in this frame
        Screen('Flip', window);
        % Response Collection during stimulus presentation
        [pressed, firstPress] = KbQueueCheck();
        if pressed
            % Check if the 'left' or 'right' key has been pressed
            leftPressed = firstPress(leftKey) > 0;
            rightPressed = firstPress(rightKey) > 0;
            % If one of the response keys was pressed, handle the response
            if leftPressed || rightPressed
                responses(1, trial) = handle_response(firstPress, leftKey, rightKey, escapeKey, window);
                responses(2, trial) = GetSecs() - startTime;
            elseif firstPress(KbName('ESCAPE'))
                disp('Experiment aborted by the user');
                Screen('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
                Screen('Flip',window);
                pause(0.3);
                Screen('Closeall');
                sca; ShowCursor;  % Close the screen and show the cursor
                return;
            end
        end
    end
    
    % Present a black line for 2 seconds (common to all trials); collect
    % responses
    while (GetSecs() - experimentStartTime) < trialEnds(trial)
        Screen('DrawTexture', window, cueTexture, [], CenterRectOnPointd([0 0 cueSize cueSize], xCenter, yCenter));
        Screen('Flip', window);
        [pressed, firstPress] = KbQueueCheck();
        if pressed
            % Check if the 'left' or 'right' key has been pressed
            leftPressed = firstPress(leftKey) > 0;
            rightPressed = firstPress(rightKey) > 0;
            % If one of the response keys was pressed, handle the response
            if leftPressed || rightPressed
                responses(1, trial) = handle_response(firstPress, leftKey, rightKey, escapeKey, window);
                responses(2, trial) = GetSecs() - startTime;
            elseif firstPress(KbName('ESCAPE'))
                disp('Experiment aborted by the user');
                Screen('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
                Screen('Flip',window);
                pause(0.3);
                Screen('Closeall');
                sca; ShowCursor;  % Close the screen and show the cursor
                return;
            end
        end
    end
end

% One extra blank at the end to capture response to last trial (12 seconds)
Screen('DrawTexture', window, cueTexture, [], CenterRectOnPointd([0 0 cueSize cueSize], xCenter, yCenter));
Screen('Flip', window);
WaitSecs(12)

% Restore gamma correction to default
Screen('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
Screen('Flip', window);
pause(0.3);
Screen('CloseAll');
% Close the screen and show the cursor
sca;
ShowCursor;
% Cleanup (after the main loop)
KbQueueStop;
KbQueueRelease;

plotResults(responses, trialOrder)
%%
if eyeTrack == 1
    eyelink_init3
end

%% save a bunch of stuff

savePath = 'data';

% The first-level directory is subject specific
% Construct the directory 
subDirName = sprintf('sub-%s', subjectCode);

% Does subject directory exist? If not, try creating it
subDirPath = fullfile(savePath, subDirName);
if ~exist(subDirPath, 'dir')
    [status, msg] = mkdir(subDirPath);
    if ~status
        error('Failed to create directory: %s. Error: %s', subDirPath, msg);
    end
end

% Construct filename
filename = sprintf('sub-%s_ses-%s_run-%d.mat', subjectCode, experimentName, runNumber);

% Construct the full save path
savePath = fullfile(savePath, subDirName, filename);

scriptContent = fileread('cube_96.m');

% Try saving the data
try
    save(savePath, 'responses', 'trialOnsets', 'trialOrder', 'display','scriptContent');
catch ME
    error('Failed to save data to: %s. Error: %s', savePath, ME.message);
end

if eyeTrack == 1
    % Check if the edfFile variable exists and is not empty
    if exist('edfFile', 'var') && ~isempty(edfFile)
        % Construct the full path to the destination
        destEdfPath = fullfile(logfilesPath, subDirName, sessionDirectory, [edfFile '.edf']);
        
        % Check if the source .edf file exists
        if exist([edfFile '.edf'], 'file')
            % Move the .edf file to the desired directory
            try
                movefile([edfFile '.edf'], destEdfPath);
            catch ME
                error('Failed to move the .edf file to: %s. Error: %s', destEdfPath, ME.message);
            end
        else
            error('The specified .edf file (%s) does not exist.', edfFile);
        end
    else
        warning('eyeTrack is set to 1, but no valid edfFile variable was provided.');
    end
end

% INTERNAL FUNCTIONS START HERE
%%
function response = handle_response(firstPress, leftKey, rightKey, escapeKey, window)
    if firstPress(leftKey)
        response = 1;  % or 'left' if using cell array
    elseif firstPress(rightKey)
        response = 2;  % or 'right' if using cell array
    elseif firstPress(escapeKey)
        disp('Experiment aborted by the user');
        Screen('LoadNormalizedGammaTable', window, (0:255)'*ones(1,3)./255,2);
        Screen('Flip',window);
        pause(0.3);
        Screen('Closeall');
        sca; ShowCursor;  % Close the screen and show the cursor
        error('Experiment terminated by user');  % Throw an error
        return;  % End the script
    else
        response = NaN;  % You can also default to NaN or 'no response' for clarity
    end
end


%%
function cueB = makeBullseyeCue(d1, d2, ppd)
    cueB = zeros(floor(d1*ppd));
    cueB(:) = 0.5;

    % Draw first oval
    radius1 = d1 * ppd / 2;
    [x1, y1] = meshgrid(1:d1*ppd, 1:d1*ppd);
    circleMask1 = (x1 - d1*ppd/2).^2 + (y1 - d1*ppd/2).^2 <= radius1^2;
    
    % Set the circular region to 1 in the matrix
    cueB(circleMask1) = 0;
    
    % Draw the white cross
    thickness = floor(d2*ppd); % Adjust the thickness of the cross as needed

    % Draw horizontal line
    cueB(round(d1*ppd/2-thickness/2):round(d1*ppd/2+thickness/2), :) = 1;

    % Draw vertical line
    cueB(:, round(d1*ppd/2-thickness/2):round(d1*ppd/2+thickness/2)) = 1;
    
    % Draw second oval
    radius2 = d2 * ppd / 2;
    circleMask2 = (x1 - d1*ppd/2).^2 + (y1 - d1*ppd/2).^2 <= radius2^2;
    
    % Set the circular region to 1 in the matrix
    cueB(circleMask2) = 0;
end

% Create the green square bitmap function
function cueBitmap = makeFixation(cueSize)
    % Generate a bitmap filled with green color
    cueBitmap = zeros(cueSize, cueSize, 3); % Initialize with black
    cueBitmap(:,:,2) = 1; % Only the G channel is set to 1, making it green
end

function plotResults(responses, trialOrder)
    orientations = [0, 45, 90, 135, 180, 225, 270, 315];

    reactionTimes = responses(2,:);
    orientations = orientations(trialOrder);

    unique_orientations = unique(orientations);

    mean_reactionTimes = zeros(size(unique_orientations));

    % Compute the mean reaction time for each unique orientation
    for i = 1:length(unique_orientations)
        % Find indices of the current orientation
        indices = (orientations == unique_orientations(i));
        
        % Calculate the mean reaction time for the current orientation
        mean_reactionTimes(i) = mean(reactionTimes(indices));
    end

    meanRT = mean_reactionTimes(~isnan(mean_reactionTimes));
    rotAngle = unique_orientations(~isnan(unique_orientations));

    figure
    plot(rotAngle, meanRT)
    set(gca,'xtick',rotAngle)
    xlabel('Rotation Angle')
    ylabel('RT')
end