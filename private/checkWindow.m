% pulled out of pointProcess cause static method couldn't call itself?
% may as well use it in alignTimes

function validWindow = checkWindow(window,n)
% Validate window, and replicate if necessary
% 
% % single window
% [start end]
% 
% % one window for each of n elements
% [start(1,1) end(1,1)
%    start(2,1) end(2,1)
%    start(n,1) end(n,1)
%    ]
% 
% % aribitrary windows for each of n elements
% {
%   [start(1,1) end(1,1)   [start(1,2) end(1,2)   [start(1,n) end(1,n)]
%    start(2,1) end(2,1)]   start(2,2) end(2,2)]
%  }
% 
% For example, to use the same set of windows for n elements,
% checkWindow({[-6 0;0 6;-6 6]},n)
% 
if nargin == 1
   n = 1;
end

if iscell(window)
   % Same windows for each element
   if numel(window) == 1
      window(1:n) = window;
   end
   % Different windows for each element
   if numel(window) == n
      for i = 1:n
         validWindow{1,i} = checkWindow(window{i},size(window{i},1));
      end
   else
      error('Cell array window must be {[nx2]} or [nObjs x 2]');
   end
else
   if numel(window) == 2
      window = window(:)';
      window = repmat(window,n,1);
   end
   if size(window,1) ~= n
      error('Array window must be [1 x 2] or [nObjs x 2]');
   end
   if any(window(:,1)>window(:,2))
      error('First element of window must be less than second');
   end
   validWindow = window;
end
