function list = K_importXYZ_csv2masterxlsx(csvname, excelpath)
%  list = K_importXYZ_csv2masterxlsx(csvname, excelpath)
%
% K_importXYZ_csv2masterxlsx imports X, Y, and Z coordinates from *.csv file
% (prepared by extract.py written by Dr Takuma Tanaka) and insert the values to
% the specified cells in Excel file excelpath.
%
% This script is outside the file synchronizing routines, such as sync.m.
%
% Written by Kouichi C. Nakamura Ph.D.
% Dept Morphological Brain Science
% Kyoto University, Japan
% kouichi.c.nakamura@gmail.com
% 12-May-2015 18:18:02
%
% See also
% K_importXYZ_csv2masterxlsx_test, K_importXYZ_csv2masterxlsx_fixture, extract.py

% if ~ispc
%     error(eid('notpc'),...
%         'This function "K_importXYZ_csv2masterxlsx" requires "xlswrite" which only runs properly in PC.')
% end

%% Read the .CSV file csvname

[probenames, probedata, injectionnames, injectiondata ] = local_readCSV(csvname);


%% Read the .XLSX file excelpath

[~,~,raw]= xlsread(excelpath);

header = pvt_cell_NaN2EmptyString(raw(1, :));

[col_recX, col_injX] = local_assert_XYZ(header, csvname, raw);


%% Save backup -- important
nowstr = [datestr(now, '_yyyy-mm-dd_HHMMSS'), '.xlsx'];

copyfile(excelpath, regexprep(excelpath, '.xlsx$', nowstr));


%% find the target in raw

if ~isempty(probenames)
    list1 = local_editExcel(probenames, probedata, raw, csvname, excelpath, col_recX);
else
    list1 = {};
end


if ~isempty(injectionnames)
    list2 = local_editExcel(injectionnames, injectiondata, raw, csvname, excelpath, col_injX);
else
    list2 = {};
end


list = [list1; list2];

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [probenames, probedata, injectionnames, injectiondata ] = local_readCSV(csvname)

fid = fopen(csvname, 'r');
nchannels = 16;

probenames = cell(0);
probedata = cell(0);
injectionnames = cell(0);
injectiondata = cell(0);

while ~feof(fid)
    label = strrep(fgetl(fid), '#', '');

    if ~isempty(strfind(label, 'Injection')) || ~isempty(strfind(label, 'Juxta'))

        labelsplt = strsplit(label, ',');

        match = labelsplt(cellfun(@(x) ~isempty(x), ...
            regexp(labelsplt, '[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}')));
        %TODO no distinction between injection and juxta, is it OK?

        injectionnames = [injectionnames;match'];

        % fscanf cannot output mixture of number and string into cell array
        newrow = strsplit(fgetl(fid),',');
        newrow(1, [1:3,5:end]) = num2cell(str2double(newrow(1, [1:3,5:end]))); % convert the cell contents to double format except slice ID
        newrow = [newrow, cell(1, 5 - length(newrow))]; % pad with empty cells

        if  ~isempty(strfind(label, 'Injection'))
            newrow{end+1} = 'Injection';
        elseif ~isempty(strfind(label, 'Juxta'))
            newrow{end+1} = 'Juxta';
        end

        newrows = repmat({newrow}, length(match), 1); % copy according to the number of matches
        injectiondata = [injectiondata; newrows];

    else % Probe

        probenames = [probenames;label];

        % fscanf cannot output mixture of number and string into cell array
        buffer = cell(0, 0);
        for i = 1:nchannels
            newrow = strsplit(fgetl(fid),',');
            newrow(1, [1:3,5:end]) = num2cell(str2double(newrow(1, [1:3,5:end]))); % convert the cell contents to double format except slice ID
            newrow = [newrow, cell(1, 8 - length(newrow))]; % pad with empty cells
            buffer = [buffer; newrow];
        end
        probedata = [probedata; {buffer}];

    end
end
fclose(fid);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [col_recX, col_injX] = local_assert_XYZ(header, csvname, raw)
assert( all(ismember({'recX','recY','recZ', ...
    'isinjection', 'injX' 'injY', 'injZ'}, header)),...
    eid('raw:recXYZ:absent'),...
    ['The header row of the Excel file %s does not contain all of recX, recY, and recZ',...
    'isinjection, injX, injY, injZ'], csvname);

col_recX = local_findcol(raw, 'recX');
col_recY = local_findcol(raw, 'recY');
col_recZ = local_findcol(raw, 'recZ');

col_injX = local_findcol(raw, 'injX');
col_injY = local_findcol(raw, 'injY');
col_injZ = local_findcol(raw, 'injZ');

assert(col_recZ - col_recY == 1 && col_recY - col_recX == 1,...
    eid('raw:recXYZ:notconsecutive'),...
    'recX, recY, recZ must be consective across columns.');

assert(col_injZ - col_injY == 1 && col_injY - col_injX == 1,...
    eid('raw:injXYZ:notconsecutive'),...
    'injX, injY, injZ must be consective across columns.');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function list = local_editExcel(names, csvdata, raw, csvname, excelpath, col_X)

col_electrode = local_findcol(raw, 'Electrode');
col_animal = local_findcol(raw, 'Animal');
col_record = local_findcol(raw, 'Record');

col_isinjection = local_findcol(raw, 'isinjection');
col_probemode = local_findcol(raw, 'ProbeMode');

col_injX = local_findcol(raw, 'injX');

if col_injX == col_X
    %  this call is for injection/juxta
    isforinjection = true;
else
    isforinjection = false;
end


list =cell(0, 2);
for i = 1:length(names)

    animalid = regexp(names{i}, '(^[a-zA-Z-_]{3,6}\d{1,3})[a-zA-Z]{1,2}', 'tokens');
    animalid = animalid{1}{1};

    locationid = regexp(names{i}, '^[a-zA-Z-_]{3,6}\d{1,3}([a-zA-Z]{1,2})', 'tokens');
    locationid = locationid{1}{1};

    recordnumber = regexp(names{i}, '^[a-zA-Z-_]{3,6}\d{1,3}[a-zA-Z]{1,2}(\d{2})', 'tokens');
    if isempty(recordnumber)
        recordnumber = '';
    else
        recordnumber = recordnumber{1}{1};
    end


    rows_animal = find(strcmpi(animalid, raw(:, col_animal)));

    if isempty(rows_animal)
        error(eid('local_editExcel:raw:rows:empty'),...
            'The Excel file %s does not contain data for animal %s', csvname, animalid);
    end

    cellsthisanimal = pvt_cell_NaN2EmptyString(raw(rows_animal, col_record));

    if isempty(recordnumber)
        rows_loc = ismatched(cellsthisanimal, ['^(', locationid, ')\d\d']);
    else
        rows_loc = ismatched(cellsthisanimal, ['^', locationid, recordnumber, '$']);
    end

    toprows = rows_animal(rows_loc); % could have multiple matches

    %% Edit the Excel file
    % xlRange can only select a rectangular at a time

    for j = 1:length(toprows)

        topleft = [char('A' +col_X -1), num2str(toprows(j))];

        local_assert_electrodenumber(csvdata, raw, toprows, i, j, ...
            col_electrode, animalid, locationid);

        data = csvdata{i}(:,2:4);

        if isforinjection
            assert( raw{toprows(j), col_isinjection} == 1,...
                eid('local_editExcel:isinjection:false'),...
                'isinjection value at %s was expected to be 1. ',...
                [char('A' +col_isinjection -1) , num2str(toprows(j))]);

            switch raw{toprows(j), col_probemode}
                case '16x1'
                    data = repmat(data, 16, 1);
                case '16x2'
                    data = repmat(data, 32, 1);
                otherwise

            end
        end


        %% Writing into the Excel file
        if ispc
            xlswrite(excelpath, data, 'Detail', topleft);
        elseif ismac % xlswrite is not available

            local_assert_xlwriteformac;
            xlwrite(excelpath, data, 'Detail', topleft);

        end

        recname = [raw{toprows(j), col_animal},  raw{toprows(j), col_record}];

        m = size(data, 1);
        bottomright = [char('A' +col_X +1),  num2str(toprows(j) + m - 1)];

        xlRange = [topleft, ':', bottomright];

        fprintf('%s, %s [%dx%d], %s\n', excelpath, xlRange, size(data), recname);
        list = [list; {xlRange}, {recname}];

    end

end


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function col = local_findcol(raw, str)


%% find the column which has the specified header

TF = strcmpi(str, raw(1,:));

if nnz(TF) == 1
    col = find(TF);
else
    col = [];
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_assert_electrodenumber(csvdata, raw, toprows, i, j, col_electrode, animalid, locationid)
% Could be double 1-16 or string A01-A16,B01-B16

cell2cellstr = @(x) cellfun(@(X) strtrim(num2str(X)), x, 'UniformOutput', false);

electr_csv = cell2cellstr(csvdata{i}(:,1));
electr_raw = cell2cellstr(raw(toprows(j):toprows(j)+size(csvdata{i}, 1)-1, col_electrode));

assert(all(strcmp(electr_csv, electr_raw)),...
    eid('local_edit:electrodestring:mismatch'),...
    'The electrode numbers do not tally for %s\n', [animalid, locationid]);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_assert_xlwriteformac()
if isempty(which('xlwrite'))

    error(eid('local_editExcel:no_xlwrite'),...
        ['This function "K_importXYZ_csv2masterxlsx" requires ',...
        '<a href="http://www.mathworks.com/matlabcentral/fileexchange/38591">',...
        '"xlwrite"</a> on Mac, because the builtin "xlswrite" which only runs properly in PC.']);

else
    if ~strcmp(evalc('dbtype xlwrite 1'), ...
       sprintf('\n1     function [status, message]=xlwrite(filename,A,sheet, range)\n'))

        error(eid('local_editExcel:wrong_xlwrite'),...
            ['You have a wrong xlwrite. This function "K_importXYZ_csv2masterxlsx" requires ',...
            '<a href="http://www.mathworks.com/matlabcentral/fileexchange/38591-xlwrite--generate-xls-x--files-without-excel-on-mac-linux-win">',...
            '"xlwrite"</a> on Mac, because the builtin "xlswrite" which only runs properly in PC.']);

    end
end

javaaddpath(fullfile(fileparts(which('xlwrite')), 'poi_library'));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K:
% NOTE: onlyt to be used as a local function.
%
% input argument
% str (Optional) string in char type (row vector)
%
% output argument
% eid an error id composed of 'K:(functionname):str'

narginchk(0, 1);
p = inputParser;
p.addOptional('str', '', @(x) isempty(x) || ischar(x) && isrow(x));
p.parse(varargin{:});
str = p.Results.str;

if isempty(str)
    str = '';
else
    str = [':', str];
end

[~,m,~] = fileparts(mfilename('fullpath'));

eid = ['K:', m, str];


end
