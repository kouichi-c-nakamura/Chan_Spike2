function s = K_obj2struct(obj)
%s = K_obj2struct(obj)
%   Get strucutre s containing all properties in an object obj
%   You can use whos to check the actual memory usage of obj

origWarn = warning(); % store original state of warnings

warning off 'MATLAB:structOnObject' % disable warning for a while

s = builtin('struct', obj); % use builtin in case struct is overridden

warning(origWarn);

whos('s');


end

