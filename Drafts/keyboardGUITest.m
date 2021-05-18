%% First State Of KeyBoard GUI
cd('..') % If you are in the drafts directory
State.position = [0 0 0 0 1 0 0 0 0];
State.screen = 'Main';
keyboardHanle = figure;

% String to speak
string = '';

% Display KeyBoard
Utillity.KeyBoardGUI(State, keyboardHanle, string)

% Text to speech gender
male = 'Microsoft David Desktop - English (United States)';
female = 'Microsoft Zira Desktop - English (United States)';

%% 
pred = [3 3 3 4 3 4 3 3 3 3 4 2 2 4 3 3 4 3 3 4 3 3 4 3 3 4 3 3 4 2 4 2 2 2 4 ...
    2 2 2 2 4];
for i = 1 : length(pred)
    prediction = pred(i);
        % Update state
    [State, output] = Utillity.stateUpdate(State, prediction);
    if output
        if strcmp(output, 'Send')
            Utillity.tts(string, female)
            % Reset string
            string = '';
        elseif strcmp(output, 'Help')
            % Change string to help
            string = 'I Need Help';
            % Say 3 times help is needed
            for i = 1 : 3
                Utillity.tts(string, female)
                pause(1)
            end
            % Reset the string
            string = '';
        else
            % Add character to string
            string(end + 1) = output;
        end
    end
    
    % Display KeyBoard
    clf(keyboardHanle)
    Utillity.KeyBoardGUI(State, keyboardHanle, string)
    pause(1)
end