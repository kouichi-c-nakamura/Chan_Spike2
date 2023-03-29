function [ tf ] = K_isstable( b, a, retain )
%[ tf ] = K_isstable( b, a, retain )
%   Determine whether filter is stable
%
% isstable(b,a) returns a logical output, flag, equal to true if the filter
% specified by numerator coefficients, b, and denominator coefficients, a,
% is a stable filter. If the poles lie on or outside the circle, isstable
% returns false. If the poles are inside the circle, isstable returns true.
%
% OPTION
% retain      true or false
%             true to retain fvtool window. 
%             false to close the window (default).

%% parse

narginchk(2,3)

p1 = inputParser;

vf1= @(x) isnumeric(x) &&...
    isrow(x);

addRequired(p1, 'b', vf1);
addRequired(p1, 'a', vf1);
parse(p1, b, a);

if exist('retain', 'var')
    p2 = inputParser;
    
    vf2 = @(x) isscalar(x) &&...
        islogical(x) || ...
        isnumeric(x) && ...
        x == 0 || x == 1;
    
    addRequired(p2, 'retain', vf2);
    parse(p2, retain);
    
else
    retain = false;
    
end

%% job

h =fvtool(b, a, 'Analysis','info');
set(gcf, 'Visible', 'off');
li = findobj(h, 'Style', 'listbox');
results=get(li, 'String');
stable = results{6};

if ~isempty(regexp(stable, 'Yes', 'ONCE'))
    tf = true;
else 
    tf = false;
end

if ~retain 
    close gcf
else 
    set(gcf, 'Visible', 'on');
end


