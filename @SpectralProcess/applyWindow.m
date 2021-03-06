% Window event times, setting
%     times
%     values
%     index
%     isValidWindow

% TODO
%   o Windows are inclusive on both sides, does this make sense???

function applyWindow(self)

if isempty(self.times)
   return;
end

nWindowReq = size(self.window,1);
nWindowOrig = numel(self.times);
if nWindowOrig > 1
   assert(nWindowReq==nWindowOrig,'monkey!');
end

window = self.window;
b = self.tBlock;
windowedTimes = cell(nWindowReq,1);
windowedValues = cell(nWindowReq,1);
for i = 1:nWindowReq
   minWin = min(window(i,1));
   maxWin = max(window(i,2));
   if nWindowOrig == 1
      idx = 1;
   else
      idx = i;
   end
   
   times = self.times{idx};
   values = self.values{idx};
   tStart = min(times);
   tEnd = max(times);
   dim = size(values);
   dim = dim(2:end); % leading dim is always time
   
   % NaN-pad when window extends beyond process. This extension is
   % done to the nearest sample that fits in the window.
   [preT,preV] = extendPre(min(tStart,maxWin+self.dt),minWin,self.tStep,dim);
   [postT,postV] = extendPost(tEnd,maxWin-b,self.tStep,dim);
   
   % Times mark leading block edge (for TF methods stepping in blocks), so
   % we only take times where the trailing block edge also falls in window
   ind = (times>=window(i,1)) & (times<=(window(i,2)-b));
   if ~isempty(preT) && ~isempty(postT)
      windowedTimes{i,1} = [preT ; times(ind) ; postT];
      windowedValues{i,1} = [preV ; values(ind,:,:) ; postV];
   elseif isempty(preT) && ~isempty(postT)
      if sum(ind) ~= numel(times)
         windowedTimes{i,1} = [times(ind) ; postT];
         windowedValues{i,1} = [values(ind,:,:) ; postV];
      else
         windowedTimes{i,1} = [times ; postT];
         windowedValues{i,1} = [values ; postV];
      end
   elseif ~isempty(preT) && isempty(postT)
      if sum(ind) ~= numel(times)
         windowedTimes{i,1} = [preT ; times(ind)];
         windowedValues{i,1} = [preV ; values(ind,:,:)];
      else
         windowedTimes{i,1} = [preT ; times];
         windowedValues{i,1} = [preV ; values];
      end
   else
      if sum(ind) ~= numel(times);
         windowedTimes{i,1} = times(ind);
         windowedValues{i,1} = values(ind,:,:);
      else
         windowedTimes{i,1} = times;
         windowedValues{i,1} = values;
      end
   end
end

self.times = windowedTimes;
self.values = windowedValues;
