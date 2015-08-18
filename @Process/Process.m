% Abstract class for process
classdef(Abstract) Process < hgsetget & matlab.mixin.Copyable
   properties
      info@containers.Map % Information about process
   end
   properties(SetAccess = immutable)
      timeUnit            % Time representation (TODO)
      clock               % Clock info (drift-correction, TODO)
   end
   properties(Abstract)
      tStart              % Start time of process
      tEnd                % End time of process
   end
   properties(Abstract, SetAccess = protected, Hidden)
      times_              % Original event/sample times
      values_             % Original attribute/values
   end
   properties(AbortSet)
      window              % [min max] time window of interest
   end
   properties
      offset              % Time offset relative to window
                          % Note that window is applied without offset 
                          % so times can be outside of the window property
      cumulOffset         % Cumulative offset
      labels              % Label for each non-leading dimension
      quality             % Scalar information for each non-leading dimension
   end
   properties(SetAccess = protected, Transient, GetObservable)
      times = {}          % Current event/sample times
      values = {}         % Current attribute/value associated with each time
   end
   properties(SetAccess = protected, Dependent, Transient)
      isValidWindow       % Boolean if window(s) within tStart and tEnd
   end
   properties(SetAccess = protected, Hidden)
      window_             % Original window
      offset_             % Original offset
      reset_ = false      % Reset bit
      running_ = true     % Boolean indicating eager evaluation
      runnableListener_ = {}
      loadableListener_ = {}
   end
   properties(SetAccess = protected)
      lazyLoad = false    % Boolean to defer constructing values from values_
      lazyEval = false    % Boolean to defer method evaluations (see addToQueue)
      queue = {}          % Method evaluation queue/history
      isLoaded = true     % Boolean indicates whether values constructed
      version = '0.4.0'   % Version string
   end
   events
      runnable            % Elements in queue require evaluation
      loadable            % Values must be constructed from values_
   end
   
   %%
   methods(Abstract)
      chop(self,shiftToWindow)
      s = sync(self,event,varargin)
      [s,labels] = extract(self,reqLabels)
      apply(self,fun) % apply applyFunc func?
      %copy?
      plot(self)
      
      % remove % delete by label
      
      % append
      % prepend
      
      % disp (overload?)
      % head
      % tail
      
      obj = loadobj(S)
      % saveobj
   end
   
   methods(Abstract, Access = protected)
      applyWindow(self);
      applyOffset(self,offset);
      checkLabels(self)
      checkQuality(self)
   end
   
   methods(Access = protected)
      discardBeforeStart(self)
      discardAfterEnd(self)      
      addToQueue(self,varargin)
      isLoadable(self,~,~)
      loadOnDemand(self,varargin)
      isRunnable(self,~,~)
      evalOnDemand(self,varargin)
   end

   methods
      function set.info(self,info)
         assert(strcmp(info.KeyType,'char'),...
            'Process:info:InputFormat','info keys must be chars.');
         self.info = info;
      end
            
      function set.window(self,window)
         % Set the window property
         % Window applies to times without offset origin.
         % For setting window of object arrays, use setWindow.
         %
         % SEE ALSO
         % setWindow, applyWindow

         %------- Add to function queue ----------
         if ~self.running_ || ~self.lazyEval
            addToQueue(self,window);
            if self.lazyEval
               return;
            end
         end
         %----------------------------------------
         
         self.window = checkWindow(window,size(window,1));
         if ~self.reset_
            nWindow = size(self.window,1);
            % For one current & requested window, allow rewindowing current values
            if isempty(self.window) || ((nWindow==1) && (size(self.times,1)==1))
               % Reset offset
               applyOffset(self,-self.cumulOffset);
               % Expensive, only call when windows are changed (AbortSet=true)
               applyWindow(self);
               applyOffset(self,self.cumulOffset);
            else % Different windows are ambiguous, start for original
               % Reset the process
               self.times = self.times_;
               self.values = self.values_;
               
               self.cumulOffset = zeros(nWindow,1);
               applyWindow(self);
               self.offset = self.cumulOffset;
            end
         end
      end
     
      function set.offset(self,offset)
         % Set the offset property
         % For setting offset of object arrays, use setOffset.
         %
         % SEE ALSO
         % setOffset, applyOffset
         
         %------- Add to function queue ----------
         if ~self.running_ || ~self.lazyEval
            addToQueue(self,offset);
            if self.lazyEval
               return;
            end
         end
         %----------------------------------------

         newOffset = checkOffset(offset,size(self.window,1));
         self.offset = newOffset;
         applyOffset(self,newOffset);
         self.cumulOffset = self.cumulOffset + newOffset;
      end
      
      function set.labels(self,labels)
         %------- Add to function queue ----------
         if ~self.running_ || ~self.lazyEval
            addToQueue(self,labels);
            if self.lazyEval
               return;
            end
         end
         %----------------------------------------
         
         % Wrap abstract method
         labels = checkLabels(self,labels);
         self.labels = labels;
      end
      
      function set.quality(self,quality)
         %------- Add to function queue ----------
         if ~self.running_ || ~self.lazyEval
            addToQueue(self,quality);
            if self.lazyEval
               return;
            end
         end
         %----------------------------------------
         
         % Wrap abstract method
         quality = checkQuality(self,quality);
         self.quality = quality;
      end
      
      function isValidWindow = get.isValidWindow(self)
         isValidWindow = (self.window(:,1)>=self.tStart) & ...
                         (self.window(:,2)<=self.tEnd);
      end      
      
      % Assignment for object arrays
      self = setWindow(self,window)
      self = setOffset(self,offset)
      
      self = flushQueue(self)
      self = clearQueue(self)

      self = setInclusiveWindow(self)
      self = reset(self,n)
      self = undo(self,n)
      self = map(self,func,varargin)
      % Keep current data/transformations as original
      self = fix(self)

      keys = infoKeys(self,flatBool)
      bool = infoHasKey(self,key)
      bool = infoHasValue(self,value,varargin)
      info = copyInfo(self)
   end
end
