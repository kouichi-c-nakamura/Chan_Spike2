function [varargout] = methodsall(classname)
% [mnames, mlist] = methodsall(classname)
%
% Useful when you want to get the list of methods of a class. Builtin
% methods() cannot handle abstract class. methods(?classname) only returns
% general methods of class meta.class, but not of class classname.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 23-Jun-2016 21:56:36
%
% See also 
% methods, propertiesall, methodsalltable, methodsview

p = inputParser;
addRequired(p, 'classname', @(x) ischar(x) && isrow(x));
parse(p, classname);

metaclassobj = eval(['?',classname]);

assert(isa(metaclassobj, 'meta.class'),'K:methodsall:classname:invalid',...
    'failed to create a metaobject for classname %s',classname)

assert(~isempty(metaclassobj),'K:methodsall:metaclassobj:empty',...
    'failed to create a metaobject for classname %s',classname)

mlist = metaclassobj.MethodList;
mnames = {mlist(:).Name}';

if nargout >= 1
    varargout{1} = mlist;
    if nargout >= 2
        varargout{2} = mnames;
    end
else
    
    tfstatic = [mlist(:).Static]';
    
    fprintf('\nMethods for class: %s\n\n',metaclassobj.Name)
    nonsta = mnames(~tfstatic);
    fprintf('%s\n',nonsta{:})
    
    fprintf('\nStatic methods:\n\n')
    sta = mnames(tfstatic);
    fprintf('%s\n',sta{:})
    fprintf('\n')   
end
        
end