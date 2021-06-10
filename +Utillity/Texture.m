function [ArrowTexture, IdleTexture, MarkTexture] = Texture(window, Arrow, Idle, Mark)
% TEXTURE Creates texture for the PsychToolBox online training phase.


ArrowTexture(1) = Screen('MakeTexture', window, Arrow{1});
ArrowTexture(2) = Screen('MakeTexture', window, Arrow{2});
ArrowTexture(3) = Screen('MakeTexture', window, Arrow{3});
ArrowTexture(4) = Screen('MakeTexture', window, Arrow{4});

IdleTexture(1) = Screen('MakeTexture',window, Idle{1});
IdleTexture(2) = Screen('MakeTexture',window, Idle{2});
IdleTexture(3) = Screen('MakeTexture',window, Idle{3});
IdleTexture(4) = Screen('MakeTexture',window, Idle{4});

MarkTexture = Screen('MakeTexture',window, Mark);

end