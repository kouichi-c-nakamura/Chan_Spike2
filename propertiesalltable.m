function T = propertiesalltable(classname)
%propertiesalltable returns all the properties of a class specified by ?className
% in table format including hidden properties and their attributes, such as
% GetAccess, SetAccess, and Dependent. 
%
% T = propertiesalltable(classname)
% 
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 15-Aug-2017 15:21:00
%
%
% See also
% K_properties, properties, meta.class.MethodList, metaclass, K_methodstable
% saveobj, loadobj

p = inputParser;
addRequired(p, 'classname', @(x) ischar(x) && isrow(x));
parse(p, classname);

metaclassobj = eval(['?',classname]);

assert(isa(metaclassobj, 'meta.class'),'K:propertiesalltable:classname:invalid',...
    'failed to create a metaobject for classname %s',classname)

assert(~isempty(metaclassobj),'K:propertiesalltable:metaclassobj:empty',...
    'failed to create a metaobject for classname %s',classname)

%% Job

plist = metaclassobj.PropertyList;
props = properties(plist);

S = preallocatestruct(props',size(plist));

for j = 1:length(plist)
    for i = 1:length(props)
        try
            S(j).(props{i}) = plist(j).(props{i});
        catch mexc2
            if strcmp(mexc2.identifier,'MATLAB:class:NoDefaultDefined')
                
            else
                throw(mexc2)
            end
        end
    end
end

T = sortrows(struct2table(S),'Name');

T.DefiningClassName = {T.DefiningClass(:).Name}';


end

