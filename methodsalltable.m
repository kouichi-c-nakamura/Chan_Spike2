function T = methodsalltable(classname)
%methodsalltable returns all the methods of a class specified by ?className
% in table format including hidden methods and their attributes
%
% T = methodsalltable(classname)
% 
% See also 
% methodsall, methods, methodsview, meta.class.MethodList,
% metaclass, propertiesalltable

p = inputParser;
addRequired(p, 'classname', @(x) ischar(x) && isrow(x));
parse(p, classname);

metaclassobj = eval(['?',classname]);

assert(isa(metaclassobj, 'meta.class'),'K:methodsalltable:classname:invalid',...
    'failed to create a metaobject for classname %s',classname)

assert(~isempty(metaclassobj),'K:methodsalltable:metaclassobj:empty',...
    'failed to create a metaobject for classname %s',classname)

%% Job

mlist = metaclassobj.MethodList;
props = properties(mlist);

S = preallocatestruct(props',size(mlist));

for j = 1:length(mlist)
    for i = 1:length(props)
        S(j).(props{i}) = mlist(j).(props{i});
    end
end

T = sortrows(struct2table(S),'Name');

T.DefiningClassName = {T.DefiningClass(:).Name}';

end

