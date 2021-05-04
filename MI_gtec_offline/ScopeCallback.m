function ScopeCallback(block, EventType)
global chunkSignal
if recFlag == 1
    chunkSignal  = [chunkSignal, block.InputPort(1).Data];
    disp('you made it')
end
end