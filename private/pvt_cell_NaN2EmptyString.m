function C = pvt_cell_NaN2EmptyString(C)
% C = pvt_cell_NaN2EmptyString(C)
%
% C     cell array
%
% Convert cells that contains scalar NaN into cells that contains empty
% string. If the rest of cells are all cell array of strings, the resultant
% cell array is cell array of strings.
%
% See also
% K_importXYZ_csv2masterxlsx

narginchk(1,1)

p = inputParser;
p.addRequired('C', @iscell)
p.parse(C);

isnancell = cellfun(@(x) isscalar(x) && isnan(x), C);
C(isnancell) = repmat({''}, size(find(isnancell)));

end