% TODO
%  o IIR filters?

function [self,h,d] = lowpass(self,varargin)

if nargin < 2
   error('SampledProcess:lowpass:InputValue',...
      'Must at least specify ''Fc'' and ''order''.');
end

p = inputParser;
p.KeepUnmatched = true;
addParameter(p,'Fpass',[],@isnumeric);
addParameter(p,'Fstop',[],@isnumeric);
addParameter(p,'Fc',[],@isnumeric);
addParameter(p,'order',[],@isnumeric);
addParameter(p,'attenuation',60,@isnumeric); % Stopband attenuation in dB
addParameter(p,'ripple',0.1,@isnumeric); % Passband ripple in dB
addParameter(p,'method','',@ischar);
addParameter(p,'fix',false,@islogical);
addParameter(p,'plot',false,@islogical);
addParameter(p,'verbose',false,@islogical);
parse(p,varargin{:});
par = p.Results;

Fs = unique([self.Fs]);
assert(numel(Fs)==1,'Must have same Fs');

if isempty(par.order) % minimum-order filter
   assert(~isempty(par.Fpass)&&~isempty(par.Fstop),...
      'Minimum order filter requires Fpass and Fstop to be specified.');
   d = fdesign.lowpass('Fp,Fst,Ap,Ast',...
      par.Fpass,par.Fstop,par.ripple,par.attenuation,Fs);
else % specified-order filter
   if ~isempty(par.Fpass) && isempty(par.Fstop)
      d = fdesign.lowpass('N,Fp,Ap,Ast',...
         par.order,par.Fpass,par.ripple,par.attenuation,Fs);
   elseif ~isempty(par.Fpass) && ~isempty(par.Fstop)
      d = fdesign.lowpass('N,Fp,Fst,Ap',...
         par.order,par.Fpass,par.Fstop,par.ripple,Fs);
   elseif ~isempty(par.Fc) % 6dB cutoff
      d = fdesign.lowpass('N,Fc,Ap,Ast',...
         par.order,par.Fc,par.ripple,par.attenuation,Fs);
   else
      error('SampledProcess:lowpass:InputValue',...
         'Incomplete filter design specification');
   end
end

if isempty(par.method)
   h = design(d,'FilterStructure','dffir');
else
   h = design(d,par.method,'FilterStructure','dffir');
end

self.filter(h.Numerator,'a',1,'fix',p.Results.fix);

if par.plot
   fvtool(h);
end
if par.verbose
   info(h,'long');
end
