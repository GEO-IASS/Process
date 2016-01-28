% Insert times
% Note that this adjusts tStart and tEnd to include all times.
% Note that if there is already an offset, new times are added to
% original times (w/out offset), and then rewindowed and offset
%
% times  - either an array of event times to insert
%          or a containers.Map object, with keys of type 'double'
%          defining the event times to add
% values - values associated with event times to insert
% labels - strings defining which process to insert to
%
% SEE ALSO
% remove

function self = insert(self,events,labels)

if nargin < 2
   error('EventProcess:insert:InputFormat',...
      'Missing events to insert');
end

for i = 1:numel(self)
   if nargin < 4
      % Insert same times & values from all
      labels = self(i).labels;
   end

   indL = find(ismember(self(i).labels,labels));
   if any(indL)
      for j = 1:numel(indL)
         times2Insert = vertcat(events.time);
         values2Insert = events;
         
         if any(times2Insert)
            % Check that we can concatenate values
            % Values must match type of present values for contcatenation
            if (isa(values2Insert,'matlab.mixin.Heterogeneous') && isa(self.values_{indL(j)},'matlab.mixin.Heterogeneous'))
               % Merge & sort
               temp = [self(i).times{indL(j)} ; times2Insert];
               [~,I] = sort(temp(:,1));
               self(i).times{indL(j)} = temp(I,:);
               temp = [self(i).values{indL(j)} ; values2Insert];
               self(i).values{indL(j)} = temp(I);
               inserted(j) = true;
            else
               inserted(j) = false;
               warning('EventProcess:insert:InputFormat',...
                  ['times not added for ' self(i).labels{indL} ...
                  ' because value type does not match']);
            end
         else
            inserted(j) = false;
         end
      end

%       if any(inserted)
%          oldOffset = self(i).offset;
%          oldCumulOffset = self(i).cumulOffset;
%          reset(self(i));
%          applyWindow(self(i));
%          self(i).offset = oldCumulOffset - oldOffset;
%          self(i).offset = oldOffset;
%       end
   end
end
