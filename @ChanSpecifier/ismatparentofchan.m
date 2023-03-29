function [TFchan, names, TFmat] = ismatparentofchan(chanSpec, TFin)
% ismatparentofchan is just a wrapper of ismatvalid with more intuitive
% name. Returns TF logical index vector for the parent .mat files that
% contains channels specified by TFin logical vector.
%
% [TFchan, names, TFmat] = ismatparentofchan(chanSpec, TFin)
%
%
%
% See also
% ChanSpecifier.ismatvalid



[TFchan, names, TFmat] = ismatvalid(chanSpec, TFin);