function [varargout] = propertiesall(classname)
%[pnames, plist] = propertiesall(classname)
%
% Useful when you want to get the list of properties of a class. Builtin
% properties() cannot handle abstract class. properties(?classname) only
% returns general properties of class meta.class, but not of class
% classname.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 23-Jun-2016 21:56:22
%
% See also
% properties, propertiesalltable, methodsall

p = inputParser;
addRequired(p, 'classname', @(x) ischar(x) && isrow(x));
parse(p, classname);

metaclassobj = eval(['?',classname]);

assert(isa(metaclassobj, 'meta.class'),'K:propertiesall:classname:invalid',...
    'failed to create a metaobject for classname %s',classname)

assert(~isempty(metaclassobj),'K:propertiesall:metaclassobj:empty',...
    'failed to create a metaobject for classname %s',classname)


plist = metaclassobj.PropertyList;
pnames = {plist(:).Name}';

if nargout >= 1
    varargout{1} = plist;
    if nargout >= 2
        varargout{2} = pnames;
    end
else
    
    
    fprintf('\nProperties for class: %s\n\n',metaclassobj.Name)
    fprintf('%s\n',pnames{:})
    fprintf('\n')

end

end