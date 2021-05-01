function [Hz, trialLength, nClass, subID, f, numTrials, RS_len] = parameter_gui(ChunkDelayobj, AMPobj, IMPobj, RestDelayobj)


S.fh    = figure('units','pixels',...                   % set figure
              'position',[400 400 220 300],...
              'menubar','none',...
              'name','Parameter setting',...
              'numbertitle','off',...
              'resize','off');
          
S.pb    = uicontrol('style','push',...                  % set confirmation button
                 'unit','pix',...
                 'position',[60 10 100 20],...
                 'string','Ok');

S.txt(1) = uicontrol('style','text',...                 % set Hz text
                     'unit','pix',...
                     'position',[10 40 100 20],...
                     'string','Sampling rate:');
                 
S.Hz    = uicontrol('style','popupmenu',...             % set Hz options
                    'unit','pix',...
                    'position',[110 40 100 20],...
                    'string',['512';'256']);
                
S.txt(2) = uicontrol('style','text',...                 % set Buffer text
                     'unit','pix',...
                     'position',[10 70 100 20],...
                     'string','Chunk size (sec):');
                 
S.ChunkSz = uicontrol('style','edit',...                  % set Bufer options
                    'unit','pix',...
                    'position',[110 70 100 20],...
                    'string','6');
                
S.txt(3) = uicontrol('style','text',...                 % set classes text
                     'unit','pix',...
                     'position',[10 100 100 20],...
                     'string','# of classes:');
                 
S.nCls  = uicontrol('style','edit',...                  % set classes options
                    'unit','pix',...
                    'position',[110 100 100 20],...
                    'string','3');
                
S.txt(4) = uicontrol('style','text',...                 % set subID text
                     'unit','pix',...
                     'position',[10 130 100 20],...
                     'string','Subject ID:');
                 
S.subID	= uicontrol('style','edit',...                  % set subID options
                    'unit','pix',...
                    'position',[110 130 100 20],...
                    'string','777');

S.txt(5) = uicontrol('style','text',...                 % set frequency range text
                     'unit','pix',...
                     'position',[10 160 100 20],...
                     'string','Frequency range:');
                 
S.rng(1) = uicontrol('style','edit',...                 % set frequency range options
                    'unit','pix',...
                    'position',[110 160 45 20],...
                    'string','8');

S.rng(2) = uicontrol('style','edit',...                 % set frequency range options
                    'unit','pix',...
                    'position',[165 160 45 20],...
                    'string','40');

S.txt(6) = uicontrol('style','text',...                 % set num of trials text
                     'unit','pix',...
                     'position',[10 190 100 20],...
                     'string','# of trials:');
                 
S.nTrial = uicontrol('style','edit',...                 % set num of trials options
                    'unit','pix',...
                    'position',[110 190 100 20],...
                    'string','8');
                
S.txt(7) = uicontrol('style','text',...                 % set num of trials text
                     'unit','pix',...
                     'position',[10 220 100 30],...
                     'string','Resting-state length (sec):');
                 
S.RSlength = uicontrol('style','edit',...                 % set num of trials options
                    'unit','pix',...
                    'position',[110 225 100 20],...
                    'string','60');
                
S.txt(8) = uicontrol('style','text',...                 % set Impedance text
                     'unit','pix',...
                     'position',[10 260 100 20],...
                     'string','Show impedance:');
                 
S.chkbx = uicontrol('style','checkbox',...              % set Impedance checkbox
                    'unit','pix',...
                    'position',[150 260 20 20]);
                
                
                
                
set(S.chkbx,'callback',{@chkbx_call,IMPobj});       % Set the callback, pass hands.

set(S.pb,'callback',{@pb_call,ChunkDelayobj,AMPobj,RestDelayobj,S});   % Set the callback, pass hands.

uiwait(S.fh);                                       % wait for user reaction

[Hz, trialLength, nClass, subID, f, numTrials, RS_len] = extract_parameters(S); % extract user input parameters

close(S.fh);                                        % close figure

end