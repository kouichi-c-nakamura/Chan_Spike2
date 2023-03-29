function out = regexptrial(str, expression, replace, varargin)

assert(ischar(str) && isrow(str) || iscellstr(str));

assert(ischar(expression) && isrow(expression) || iscellstr(expression) );

assert(ischar(replace) && isrow(replace)  || isempty(replace) || iscellstr(replace) );

tf = cellfun(@(x) assert(ischar(x) && isrow(x) || isnumeric(x) && isscalar(x) && fix(x) == x), varargin);

assert(all(tf));


% JOB

% out = regexprep(str, expression, replace, varargin{:});

out = regexp(str, expression, varargin{:});


end