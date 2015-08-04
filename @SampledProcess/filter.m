% TODO
%   o edge padding, handle nan padding (filter state?, replace nans?)
%   x different filtering methods (causal, etc.)
%   o batched (looped) filtering (eg. for memmapped data)
%   o compensateDelay should be 'filtfilt' 'grpdelay' 'none',
%     then add parameter in filtering functions to compensate if using
%     filtfilt (halve order, and sqrt attenuation/ripple)?

function self = filter(self,b,varargin)

p = inputParser;
p.KeepUnmatched = true;
addRequired(p,'b',@(x) isnumeric(x) || isa(x,'dfilt.dffir'));
addParameter(p,'a',1,@isnumeric);
addParameter(p,'compensateDelay',true,@islogical);
parse(p,b,varargin{:});

if isa(b,'dfilt.dffir')
   h = b;
   b = h.Numerator;
   a = 1;
else
   a = p.Results.a;
end

for i = 1:numel(self)
   for j = 1:size(self(i).window,1)
      if p.Results.compensateDelay
         self(i).values{j} = filtfilt(b,a,self(i).values{j});
      else
         self(i).values{j} = filter(b,a,self(i).values{j});
      end
   end
end
