% resample data in window
function self = resample(self,newFs)

for i = 1:numel(self)
   if self(i).Fs == newFs
      continue;
   end
   
   % use lcm?
   % http://www.mathworks.com/matlabcentral/fileexchange/45329-sample-rate-conversion/content/SRC/srconv.m
   [p,q] = rat(newFs/self(i).Fs);
   
   % Resample first window and cache the filter
   [values{1},b] = resample(self(i).values{1},p,q);
   nWindow = size(self(i).window,1);
   if nWindow > 1
      values(2:nWindow,1) = cellfun(@(x) resample(x,p,q,b),...
         self(i).values(2:nWindow,1),'uni',0);
   end
   
   times = cellfun(@(x,y) self(i).tvec(x(1),1/newFs,size(y,1)),...
      self(i).times,values,'uni',0);
   
   self(i).times = times;
   self(i).values = values;
   self(i).Fs = newFs;
end