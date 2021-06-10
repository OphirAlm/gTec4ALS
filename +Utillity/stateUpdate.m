function [newState, output] = stateUpdate(currentState, Command)
% STATEUPDATE Gets the input command, and changes the state of the system (screen
% and pointer position).
%
% INPUT:
%     - currentState - Structure with two fields:
%         - position - 1-Hot vector
%         - screen - The name of the current screen to present
%     - Command - The prediction of the system, which decides next move.
%
% OUTPUT:
%     - newState - Updated structure with two fields:
%         - position - 1-Hot vector
%         - screen - The name of the current screen to present
%     - output - Chosen key
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    newLoc = idx + 1;
    % If index out of bounds, return to first
    if newLoc > pos_N
        newLoc = 1;
    end
    % Update new state
    newState.position = zeros(1, pos_N);
    newState.position(newLoc) = 1;
    newState.screen = currentState.screen;
    
    % If Left Command
elseif Command == 3
    newLoc = idx - 1;
    % If index out of bounds, return to first
    if newLoc == 0
        newLoc = pos_N;
    end
    % Update new state
    newState.position = zeros(1, pos_N);
    newState.position(newLoc) = 1;
    newState.screen = currentState.screen;
% If Down Command
elseif Command == 4
    % Get options per current screen
    if strcmp(currentState.screen, 'Main')
        opts = [{'A-E'}, {'F-K'}, {'L-P'}, {'Q-U'}, {'V-Z'}, {'numMenu'}, {'Space'},...
            {'Send'}, {'Lock'}];
    elseif strcmp(currentState.screen, 'A-E')
        opts = [{'A'}, {'B'}, {'C'}, {'D'}, {'E'}, {'Back'}];
    elseif strcmp(currentState.screen, 'F-K')
        opts = [{'F'}, {'G'}, {'H'}, {'I'}, {'J'}, {'K'}, {'Back'}];
    elseif strcmp(currentState.screen, 'L-P')
        opts = [{'L'}, {'M'}, {'N'}, {'O'}, {'P'}, {'Back'}];
    elseif strcmp(currentState.screen, 'Q-U')
        opts = [{'Q'}, {'R'}, {'S'}, {'T'}, {'U'}, {'Back'}];
    elseif strcmp(currentState.screen, 'V-Z')
        opts = [{'V'}, {'W'}, {'X'}, {'Y'}, {'Z'}, {'Back'}];
    elseif strcmp(currentState.screen, 'numMenu')
        opts = [{'0-4'}, {'5-9'}, {'?'}, {'.'}, {'!'}, {'Backspace'}, {'Back'}];
    elseif strcmp(currentState.screen, '0-4')
        opts = [{'0'}, {'1'}, {'2'}, {'3'}, {'4'}, {'Back'}];
    elseif strcmp(currentState.screen, '5-9')
        opts = [{'5'}, {'6'}, {'7'}, {'8'}, {'9'}, {'Back'}];
    end
    
    if strcmp(currentState.screen, 'Main')
        if idx < 7
            newState.screen = opts{idx};
            % Check for the 7 or 6 menu options
            if idx == 2 || idx == 6
                newState.position = [0 0 0 1 0 0 0];
            else
                newState.position = [0 0 1 0 0 0];
            end
            % Return space
        elseif idx == 7
            output = ' ';
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return Send
        elseif idx == 8
            output = 'Send';
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return Help
        elseif idx == 9
            output = 'Lock';
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
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'F-K')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'L-P')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'Q-U')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'V-Z')
        % Back to main menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Return the current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, 'numMenu')
        % Return to main menu
        if idx == pos_N
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            % Open numbers menu
        elseif idx < 3
            newState.position = [0 0 1 0 0 0];
            newState.screen = opts(logical(currentState.position));
            % Return current character
        else
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
            output = opts{idx};
        end
        
    elseif strcmp(currentState.screen, '0-4')
        % Return to numbers menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 1 0 0 0];
            newState.screen = 'numMenu';
        % Return current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    elseif strcmp(currentState.screen, '5-9')
        % Return to numbers menu
        if currentState.position(pos_N) == 1
            newState.position = [0 0 0 1 0 0 0];
            newState.screen = 'numMenu';
            % Return current character
        else
            output = opts{idx};
            newState.position = [0 0 0 0 1 0 0 0 0];
            newState.screen = 'Main';
        end
        
    end
end



