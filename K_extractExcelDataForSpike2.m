function [list, skipped] = K_extractExcelDataForSpike2(excelpath, destfolder, varargin)
% Read the 'kjx data summary.xlsx' file in "excelpath", take out relevant
% information, and save them into .xlsx files (.csv doesn't support export
% from a cell array) in a predetermined folder "destfolder". Those data can
% be later imported into .mat recording data files exported from Spike2
% with K_importExcelData2structSpike2().
%
% [list, skipped] = K_extractExcelDataForSpike2(excelpath, destfolder)
% [list, skipped] = K_extractExcelDataForSpike2(excelpath, destfolder, rowrange)
% [list, skipped] = K_extractExcelDataForSpike2(excelpath, destfolder, regexp)
% [list, skipped] = K_extractExcelDataForSpike2(excelpath, destfolder, regexpC, outnamestem)
%
%
% In order to change columns in Excel worksheet to be extracted, edit the
% content of a cell array of strings "Header". 
%
%
% INPUT ARGUMENTS
%     excelpath        Excel spread sheet
%
%     destfolder       Destination folder for saving (it can be different 
%                      from the location where the recording files are)
%
%     rowrange         (Optional)
%                      A vector of the row numbers in the Excel file that
%                      are to be extracted. For example
%
%                            rowrange = 20:30 
%
%                      limits the operation to the rows 20 to 30 inclusive.
%                      You can specify discontinuous row numbers by
%                      creating a row (horizontal) vector of row numbers
%                      (positive integers) for the processing.
%                      For probe data, rowrange must contain the first row
%                      of the 16 or 32 record. Otherwise, that row in probe
%                      data will be ignored.
%
%     regexp           (Optional, alternative)
%                      String for regular expression. Limits the operation
%                      to the rows whose concatenated names (that is [Animal
%                      Record]) match regexp. for example,
%
%                          regexp = 'kjx127|kjx135';
%
%     regexpC          Cell vector or regular expressions used in
%                      combination with outnamestem. Each element of the
%                      cell specifies one file. If more than two output
%                      files are created, an error is issued.
%
%     outnamestem      Cell vector of strings for the stem of output file
%                      names. outnamestem and regexpC must have the same
%                      length.
%
% OUTPUT ARGUMENTS
% list                 names of generated *_info.xlsx files. 
%
% skipped              names of skipped files that had no need to be updated
%
%
% 12 Nov 2014
% Written by Dr Kouichi C. Nakamura
% kouichi.c.nakamura@gmail.com
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 25-Jul-2017 11:47:55
%
%
% See also
% K_importExcelData2structSpike2, K_importXYZ_csv2masterxlsx


% TODO   Header can be made into an input argument
%        or can be made into a property of a class

%% Parameter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Header = {'Animal', 'Record', 'Electrode', 'ProbeMode', 'Dopamine',...
    'Tag', 'Stim', 'Description', 'Label', 'Location', 'Identified',...
    'Note for Labeled Cell', 'Spike sorting','SUA Copied to Analysis Folder',...
    'LFP Copied to Analysis Folder', 'recX', 'recY', 'recZ', 'isinjection', ...
    'injX', 'injY', 'injZ','injLocation'};

% Excat column headers for the Excel file. They must be unique. Only
% columns with these headers are to be extracted.
%
%  If you add a new header, then you will also need modify the code of
%  K_importExcelData2structSpike2. Need to add a new field to structure S
%  to store the added data.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% parse

narginchk(2,4);

p = inputParser();

vf1 = @(x) ischar(x) && isrow(x) && ~isempty(x) && any(regexp(x, '.xlsx$'));
addRequired(p, 'excelpath', vf1);

vf2 = @(x) isdir(x) && isrow(x) && ~isempty(x) ;
addRequired(p, 'destfolder', vf2);

if nargin <= 3

    vf3 = @(x) isvector(x) && isnumeric(x) && all(x > 0) && all(fix(x) == x) || ...
        ischar(x) && isrow(x) ||...
        iscellstr(x) && isvector(x);
    addOptional(p, 'rowrange', [], vf3);
    
    parse(p, excelpath, destfolder, varargin{:});
    
    rowrange = p.Results.rowrange;
    
    outnamestem = [];
    
    rowrangeC = {rowrange};

else
   
    
    vf3 = @(x) isvector(x) && iscellstr(x);
    addOptional(p, 'regexpC', [], vf3);
    
    vf3 = @(x) isvector(x) && iscellstr(x);
    addOptional(p, 'outnamestem', [], vf3); 
    
    parse(p, excelpath, destfolder, varargin{:});
    
    rowrangeC = p.Results.regexpC;
    
    outnamestem = p.Results.outnamestem;
    
    assert(length(rowrangeC) == length(outnamestem));


end


%% job

[~, ~, raw] = xlsread(excelpath);

listC = cell(length(rowrangeC), 1);
skipped = {};

for j = 1:length(rowrangeC)
    
    rowrange = rowrangeC{j};
    

    

    if isempty(rowrange)
        rowrange = 2:size(raw, 1);
    elseif isnumeric(rowrange)
        assert( all(rowrange <= size(raw, 1)),...
            eid('rowrange:exceed'),...
            'Some of values in rowrange exceeded the number of rows (%d) in the specified Excel file.', size(raw, 1));
        
        if iscolumn(rowrange)
            rowrange = rowrange'; % index values must be a horizontal vector
        end
    else
        if ischar(rowrange)
            rowrange = {rowrange};
        end
        
        %TODO analyse the regexp
        
        rowrangevec = zeros(size(raw, 1), 1);
        
        col_Animal = local_findcol(raw, 'Animal');
        col_Record = local_findcol(raw, 'Record');
        for i = 2:size(raw, 1)
            
            if ischar(raw{i, col_Animal}) && ischar(raw{i, col_Record})
                
                name = [raw{i, col_Animal}, raw{i, col_Record}];
                
                startIndex = regexp(name, rowrange, 'ONCE');
                
                if any(~isempty([startIndex{:}]))
                    rowrangevec(i) = 1;
                end
            end
            
        end
        rowrange = find(rowrangevec)';
        
    end
    
    if ~isempty(outnamestem) ...
            && length(rowrange) ~= 1
        
        error('In 4 input arguments syntax, each element of regexpC must specify one file. But element %d has more than two hits.',j)
    end
    
    % while i < rowend
    
    list = cell(length(rowrange), 1);
    k = 0;
    
    for i = rowrange
        k = k + 1;
        
        %% animal
        % maybe not always contain kjx* due to merged cells
        
        j_animal = local_findcol(raw, 'Animal');
        if iscellstr(raw(i,j_animal)) && ~isempty(raw(i,j_animal))
            if regexp(raw{i,j_animal}, '^kjx\d\d\d\.*') == 1 % very strict
                
                %% judge if probe or juxta
                
                j_record = local_findcol(raw, 'Record');
                j_probemode = local_findcol(raw, 'ProbeMode');
                j_electrode =  local_findcol(raw, 'Electrode');
                probemode = local_probemode(raw, i, j_record, j_probemode, j_electrode);
                
                
                %%
                
                switch probemode
                    case '0'
                        % juxta data
                        rows = 1;
                        
                    case '16x1'
                        rows = 16;
                    case '16x2'
                        rows = 32;
                    otherwise
                        rows = 1;
                end
                
                % preallocation
                buffer = cell(rows+1,length(Header));
                buffer(1,:) = Header;
                
                % assert
                row1 = raw(1,:);
                ind_filled = ~cellfun(@(x) ~ischar(x) && isnan(x), row1);
                mismatches = setdiff(Header, raw(1,ind_filled));
                
                s_ = strjoin(repmat({'%s'}, 1, length(mismatches)), ', ');
                assert(isempty(mismatches),...
                    'K:K_extractExcelDataForSpike2:HeaderMismatch',...
                    ['It appears that the headers (top row) in the master Excel file %s has been changed. \n', ...
                    s_, '\n' ...
                    'You may need to ammend the definition of the Header variable in K_extractExcelDataForSpike2 to remove surplus headers.'], ...
                    excelpath, mismatches{:});
                clear row1 ind_filled
                
                for x = 1:rows
                    
                    col_Record = local_findcol(raw, 'Record');
                    thisRecord = raw{i, col_Record};
                    
                    % skip if 'Record' is empty (NaN)
                    if all(isnan(thisRecord))
                        % skip this x
                        buffer = [];
                        continue
                    end
                    
                    for y = 1:length(Header) % go through columns in Header
                        j_animal = local_findcol(raw, Header{y});
                        if j_animal > 0
                            if any(strcmp(Header{y}, {'Animal', 'Record'}))
                                
                                buffer{x+1, y} = raw{i,j_animal};
                                
                            else
                                
                                buffer{x+1, y} = raw{i+x-1,j_animal};
                                
                            end
                        else
                            warning('K:K_extractExcelDataForSpike2:HeaderNotFound',...
                                'Header "%s" was not found in raw for %s%s', ...
                                Header{y}, raw{i, j_animal}, thisRecord);
                        end
                    end
                end
                
                %% write
                
                if ~isempty(buffer)
                    animalname = buffer{2, strcmp(Header, 'Animal')};
                    
                    recordname =  [animalname(1:6), ... % ignore the suffix .... rather dangerous
                        buffer{2, strcmp(Header, 'Record')}];
                    
                    if isempty(outnamestem)
                        dest = fullfile(destfolder, [recordname, '_info.xlsx']);
                    else
                        dest = fullfile(destfolder, [outnamestem{j}, '_info.xlsx']);
                    end
                    
                    if exist(dest, 'file') == 2
                        
                        [~, ~, raw2] = xlsread(dest); % SLOW
                        
                        if isequaln(buffer, raw2)
                            % no need to update dest because identical
                            clear raw2
                            
                            skipped = [skipped; dest]; %#ok<AGROW>
                            continue;
                            
                        end
                        clear raw2
                    end
                    try
                        xlswrite(dest, buffer); % csvwrite cannot handle a cell array
                    catch ME1
                        dbstop
                        throw(ME1)
                    end
                    fprintf('%s\n', dest);
                    list(k) = {dest};
                end
                
                continue;
                
                
            else
                % does not match kjx000 format
                %TODO what about animals provided from others?
                
                % skip this row
                continue;
            end
        elseif isnan(raw{i,j_animal})
            %TODO not sure
            continue; % skip this row
        else
            % warning('K:K_extractExcelDataForSpike2','');
            
            continue; % skip this row
        end
        
        
    end % for
    
    listC{j} = list;
    
end

list = vertcat(listC{:});

list(cellfun(@isempty, list)) = [];


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function probemode = local_probemode(raw, i, j_record, j_probemode, j_electrode)
%
% probemode      string
%                '0'      for not probe
%                '16x1'   for probe in 16x1 configuration 
%                '16x2'   for probe in 16x2 configuration
%
% read the ProbeMode data and make sure the data format is in order

probemode = num2str(raw{i, j_probemode});

switch lower(probemode)
    case '0'
        % not probe
    case '16x1'
        for k = 1:16
            if k == 1
                
                if ~isempty(raw(i+k-1,j_record)) && all(~isnan(raw{i+k-1,j_record})) && ...
                    ~isempty(regexp(raw{i+k-1,j_record}, '(^[a-zA-Z]{1,2}\d{1,2}$)', 'once'))                
                % Record must NOT be empty or NaN, and it must be a02 or AA01 in format

                assert( isnumeric(raw{i+k-1,j_electrode}) && isscalar(raw{i+k-1,j_electrode}) && raw{i+k-1,j_electrode} == k,...
                    eid('local_probemode:electrode'),...
                    'The Electrode value is expected to 1 through 16 increasing. However it was %d',...
                    raw{i+k-1,j_electrode});
                
                else
                    % This is not the first row of a set of probe data, so
                    % you can skip the for loop
                    
                    break
                    
                end
                
            elseif k > 1 
                assert(~isempty(raw(i+k-1,j_record)) && all(isnan(raw{i+k-1,j_record})),...
                    eid('local_probemode:record:mode16x1:k>1'),...
                    'Record must be not empty but NaN.');

                assert( isnumeric(raw{i+k-1,j_electrode}) && isscalar(raw{i+k-1,j_electrode}) && raw{i+k-1,j_electrode} == k,...
                    eid('local_probemode:electrode'),...
                    'The Electrode value is expected to 1 through 16 increasing. However it was %d',...
                    raw{i+k-1,j_electrode});
                
            end
            
        end
        
        
    case '16x2'
        
        for k = 1:32
            
            if k == 1
                
                if ~isempty(raw(i+k-1,j_record)) && all(~isnan(raw{i+k-1,j_record})) && ...
                    ~isempty(regexp(raw{i+k-1,j_record}, '(^[a-zA-Z]{1,2}\d{1,2}$)', 'once'))
                % Record must not be empty or NaN, and it must be a02 or AA01 in format
                
                
                token = regexp(raw{i+k-1,j_electrode}, '(^[AB])(\d{1,2}$)', 'tokens');
                token = token{1};
                token1 = token{1};
                token2 = token{2};
                
                assert( token1 == 'A',...
                    eid('local_probemode:electrode:mode16x2:AB'),...
                    'The Electrode value is expected to have suffix A but it was %s',...
                    token);
                
                assert( str2double(token2) == k,...
                    eid('local_probemode:electrode:mode16x2:number'),...
                    'The Electrode value is expected to 1 through 16 increasing. However it was %s',...
                    token2);
                
                else
                    % this is not the first row of a set of probe data, so
                    % you can skip the for loop
                    
                    break

                end
                
            elseif k > 1 && k <= 16
                assert(~isempty(raw(i+k-1,j_record)) && all(isnan(raw{i+k-1,j_record})),...
                    eid('local_probemode:record:mode16x1:k>1'),...
                    'Record must be not empty but NaN.');
                
                token = regexp(raw{i+k-1,j_electrode}, '(^[AB])(\d{1,2}$)', 'tokens');
                token = token{1};
                token1 = token{1};
                token2 = token{2};

                assert( token1 == 'A',...
                    eid('local_probemode:electrode:mode16x2:AB'),...
                    'The Electrode value is expected to have suffix A but it was %s',...
                    token);
                
                assert( str2double(token2) == k,...
                    eid('local_probemode:electrode:mode16x2:number'),...
                    'The Electrode value is expected to 1 through 16 increasing. However it was %s',...
                    token2);
                
            elseif  k >= 17
                assert(~isempty(raw(i+k-1,j_record)) && all(isnan(raw{i+k-1,j_record})),...
                    eid('local_probemode:record:mode16x1:k>1'),...
                    'Record must be not empty but NaN.');
                
                token = regexp(raw{i+k-1,j_electrode}, '(^[AB])(\d{1,2}$)', 'tokens');
                token = token{1};
                token1 = token{1};
                token2 = token{2};

                assert( token1 == 'B',...
                    eid('local_probemode:electrode:mode16x2:AB'),...
                    'The Electrode value is expected to have suffix A but it was %s',...
                    token);
                
                assert( str2double(token2) == k - 16,...
                    eid('local_probemode:electrode:mode16x2:number'),...
                    'The Electrode value is expected to 1 through 16 increasing. However it was %s',...
                    token2);
            end
            
        end
        
    otherwise
        
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
function eid = eid(varargin)
% eid = eid()
% eid = eid(string)
% Local function that generates error id that begins with K: 
% 
% input argument
% str        (Optional) string in char type (row vector)
%
% output argument
% eid         an error id composed of 'K:(functionname):str'

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


