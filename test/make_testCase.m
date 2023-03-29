function [] = make_testCase(name)
% [] = make_testCase(V)
% 
% name       The name of the new M file.
% 
% Example
% If you want to create a new testCase defintion named 'mytest' excute the
% the code below in the command line:
%
%     make_testCase('mytest.m')

narginchk(0, 1);

if nargin == 0
    
    prompt = 'Enter the name of a new M file.';
    dlg_title = 'User Input';
    num_lines = 1;
    defAns = {'****_test.m'};
    name = inputdlg(prompt,dlg_title,num_lines,defAns);
    
    if isempty(name) % cencelled
        return
    elseif strcmp(name, '****_test.m');
        return
    end
    name = name{1};

end


vf = @(x) ~isempty(x) && ischar(x) && isrow(x) && ~isempty(regexp(x, '^[a-zA-Z]\w*.m$', 'once'));

assert(vf(name), 'K:make_testCase:name:invalid',...
    'Name must be a valid file name for .m file with .m extention');

temp = which('testCase_test.m');
copyfile(temp,name)
edit(name)
end