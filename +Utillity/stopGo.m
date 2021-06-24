function stopGo(time)
% STOPGO documentation


% Display Stop sign
% Fill
scatter(0.2,0.25, 100000, 'r', 'filled')
% Border
scatter(0.2,0.25, 100000, 'w', 'LineWidth', 4)
%Text
text(0.2,0.25 , 'STOP',...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 90);

% Pause for the resting state time
pause(time)

% Display Go Sign
% Fill
scatter(0.2,0.25, 100000, [30 180 69]./255, 'filled')
% Border
scatter(0.2,0.25, 100000, 'w', 'LineWidth', 4)
%Text
text(0.2,0.25 , 'GO',...
    'HorizontalAlignment', 'Center', 'Color', 'white', 'FontSize', 90);

end