function self = setInclusiveWindow(self)
% Set windows to earliest and latest event times
%
% SEE ALSO
% window, setWindow, applyWindow
for i = 1:numel(self)
   tempMin = min(self(i).times_);
   tempMax = max(self(i).times_);
   if tempMin == tempMax
      self(i).window = [tempMin tempMax+eps];
   else
      self(i).window = [tempMin tempMax];
   end
end

