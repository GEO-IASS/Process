function obj = loadobj(S)

if isinteger(S)
   S = getArrayFromByteStream(S);
end

if checkVersion(S.version,'0.4.0')
   obj = SampledProcess(...
      'info',S.info,...
      'Fs',S.Fs_,...
      'values',S.values_{1},...
      'labels',S.labels,...
      'quality',S.quality,...
      'window',S.window_,... % set using original window since window_ is set internally
      'offset',S.offset_,... % set using original offset since offset_ is set internally
      'tStart',S.tStart,...
      'tEnd',S.tEnd,...
      'lazyLoad',S.lazyLoad...
      );
%    % Set parent
%    if checkVersion(S.version,'0.5.0')
%       set(obj,'segment',S.segment);
%    end
   % Now set current window/offset
   set(obj,'window',S.window);
   set(obj,'offset',S.offset);
%    % Clear queue as fresh from constructor
%    clearQueue(obj);
%    % And set queue and eval status
%    set(obj,'deferredEval',S.deferredEval);
%    set(obj,'queue',S.queue);
%    % Rerun queue if needed
%    revalOnDemand(obj);
else
   %< v 0.4.0
   obj = SampledProcess(...
      'tStart',S.tStart,...
      'tEnd',S.tEnd,...
      'Fs',S.Fs,...
      'info',S.info,...
      'values',S.values_,...
      'offset',S.offset_,...
      'window',S.window_,...
      'labels',S.labels,...
      'quality',S.quality);
   obj.window = S.window;
   obj.offset = S.offset;
end