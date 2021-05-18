function [newState, output] = stateUpdate(currentState, Command)

% Default Output is None.
output = 0;

% Index as value
idx = find(currentState.position);

% State number of locations
pos_N = length(currentState.position);

% If Idle command, do nothing
if Command == 1
    newState = currentState;
    % If Right Command
elseif Command == 2
    curLoc = idx;
    newLoc = curLoc + 1;
    % If index out of bounds, return to first
    if newLoc > pos_N
        newLoc = 1;
    end
    % Update new state
    newState.position = zeros(1, pos_N);
    newState.position(newLoc) = 1;
    % If Left Command
elseif Command == 3
    curLoc = idx;
    newLoc = curLoc - 1;
    % If index out of bounds, return to first
    if newLoc == 0
        newLoc = pos_N;
    end
    % Update new state
    newState.position = zeros(1, pos_N);
    newState.position(newLoc) = 1;
    % If Down Command
elseif Command == 4
    % Get options per current screen
    if strcmp(currentState.screen, 'Main')
        opts = ['A-E', 'F-K', 'L-P', 'Q-U', 'V-Z', 'NumMenu', 'Space',...
            'Send', 'Help'];
    elseif strcmp(currentState.screen, 'A-E')
        opts = ['A', 'B', 'C', 'D', 'E', 'Back'];
    elseif strcmp(currentState.screen, 'F-K')
        opts = ['F', 'G', 'H', 'I', 'J', 'K', 'Back'];
    elseif strcmp(currentState.screen, 'L-P')
        opts = ['L', 'M', 'N', 'O', 'P', 'Back'];
    elseif strcmp(currentState.screen, 'Q-U')
        opts = ['Q', 'R', 'S', 'T', 'U', 'Back'];
    elseif strcmp(currentState.screen, 'V-Z')
        opts = ['V', 'W', 'X', 'Y', 'Z', 'Back'];
    elseif strcmp(currentState.screen, 'numMenu')
        opts = ['0-4', '5-9', '?', '.', '!', ',', 'Back'];
    elseif strcmp(currentState.screen, '0-4')
        opts = ['0', '1', '2', '3', '4', 'Back'];
    elseif strcmp(currentState.screen, '5-9')
        opts = ['5', '6', '7', '8', '9', 'Back'];
    end
    
    if strcmp(currentState.screen, 'Main')
        if idx < 7
            newState.screen = main_opts(logical(currentState.position));
            % Check for the 7 or 6 menu options
            if idx == 2 || idx == 6
                newState.position = [0 0 0 1 0 0 0];
            else
                newState.position = [0 0 1 0 0 0];
            end
            % Return space
        elseif find(currentState.position) == 7
            output = ' ';
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return Send
        elseif find(currentState.position) == 8
            output = 'Send';
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return Help
        elseif find(currentState.position) == 9
            output = 'Help';
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'A-E')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, 'F-K')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, 'L-P')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, 'Q-U')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, 'V-Z')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, 'numMenu')
        % Return to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Open numbers menu
        elseif find(currentState.position) < 3
            newState.position = [0 0 1 0 0 0];
            newState.screen = opts(logical(currentState.position));
            % Return current character
        else
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, '0-4')
        % Return to numbers menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 1 0 0 0];
            newState.screen = 'numMenu';
            % Return current character
        else
            output = opts(logical(currentState.position));
        end
        
    elseif strcmp(currentState.screen, '5-9')
        % Return to numbers menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 1 0 0 0];
            newState.screen = 'numMenu';
            % Return current character
        else
            output = opts(logical(currentState.position));
        end
        
    end
    
    
    
    