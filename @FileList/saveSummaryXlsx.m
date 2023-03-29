function [status, message] = saveSummaryXlsx(obj, dest, additionalHeaders)
% fid = saveSummaryXlsx(obj, dest)
% fid = saveSummaryXlsx(obj, dest, additionalHeaders)
%
% dest        string. Path of the destination folder where an Excel
%             summary.xlsx file will be stored.
%
% [status, message]      xlswrite outout    
%
% additionalHeaders
%          A row vector of cellstr. In case the FileList object includes
%          extended versions of ChanInfo classes (subclasses), you can
%          specify which additional properties should be saved into the
%          Excel file. Ooptinally, you can add measuring units with a space
%          and squre brackets. Example:
%          {'measurment1 [mV]','measurement2 [sec]'}
%
%          If you don't specify additionalHeaders parameter, then all
%          additional properties will be stored (or at least MATLAB will
%          try to do it).


narginchk(2, 3);

assert(ischar(dest) && isrow(dest) && isdir(dest), ...
    'K:FileList:saveSummaryXlsx:dest:notdir', ...
    'dest string must be a directory/folder');

if nargin == 3
    assert(iscellstr(additionalHeaders) && isrow(additionalHeaders),...
        'K:FileList:saveSummaryXlsx:additionalHeaders:invalid', ...
        'additionalHeaders must be cell string row vector');
else
    additionalHeaders = {};
end

%% convert Chan.Path into relative path to the path of the Excel destination

for i = 1:length(obj.List)
    for j = 1:length(obj.List{i}.ChanInfos)
        obj.List{i}.ChanInfos{j}.Path = K_pathAbs2Rel(obj.List{i}.ChanInfos{j}.Path, dest);
    end
end


%% backup the older version of Excel.xlsx if exists

listing = dir(dest);
dircontentnames = {listing(:).name}';
tf = strcmp('summary.xlsx', dircontentnames);
if any(tf)
    if nnz(tf) == 1
        dstr = datestr(listing(tf).datenum, 'yyyy-mm-dd_HH-MM-SS'); % modification date
        destxlsxback = ['summary_' , dstr, '.back.xlsx'];
        [status, message, messageid] = copyfile(fullfile(dest, 'summary.xlsx'), destxlsxback);
        
        if status ~= 1 % if not one
            error('K:FileList:saveSummaryXlsx:backup:failure',...
                'Copying %s in %s failed. Error ID %s: %s', 'summary.xlsx', dest, messageid, message);
        end
        
    else
        error('K:FileList:saveSummaryXlsx:nnz:notOne',...
            'A file name ''summary.xlsx'' must be unique in the folder %s', dest);
    end
end
clear tf dircontentnames listing


%% prepare default Header elements

fileListHeaders = FileListHeaders;

headers = fileListHeaders.Headers;
headers_def = headers;

sheet_summary = cell(1,1);
sheet_summary(1, 1:2) = {'ListName:', obj.ListName};

sheet_summary(2:3, 1:2) = {'Date:', datestr(now, 'yyyy-mm-dd');...
    'Time:', datestr(now, 'HH:MM:SS')};

if isempty(obj.Comment)
    % prompt comment input
    obj.Comment = input('Add Comment to the FileList object before saving>> ','s');
end

sheet_summary(4,1:2) = {'Comment:', obj.Comment};

%% to support additional properties for subclass of FileList % TODO
flistpropnames = properties(obj);
additional = cell(1, (length(flistpropnames) -3) *2 );

for i = 1:length(properties(obj))
    clear val
    if ~any(strcmp( flistpropnames{i}, {'ListName', 'Comment', 'List'})) % TODO
        % TODO
        additional{i*2-1} = flistpropnames{i};
        additional{i*2} = obj.(flistpropnames{i});
    end
end

if ~isempty(additional)
    sheet_summary(5,1:length(additional)) = additional;
end

%% write data from ChanInfo

% To support additionalHeaders control
if ~isempty(additionalHeaders)
    fileListHeaders = fileListHeaders.appendHeaders(additionalHeaders);
    headers = fileListHeaders.Headers;
end

row_h = 6;

sheet_summary(row_h, 1:length(headers)) = headers_def; % default headers

thisrow = row_h;

for i = 1:length(obj.List)
    recTitlte = obj.List{i}.RecordTitle;
    
    for j = 1:length(obj.List{i}.ChanInfos)
        
        %% write ChannelTitle
        thisrow = thisrow + 1;
        
        if ~isempty(recTitlte)
            sheet_summary(thisrow, 1) = recTitlte;
            clear pos
        end
        
        %% ChanInfo
        chanprops = obj.List{i}.ChanInfos{j}.get;
        
        
        %% support subclass of ChanInfo %TODO
        
        chanpropnames = fieldnames(chanprops);
        chanpropvals = cell(length(chanpropnames), 1);
        
        %% get ChanIinfoClassName
        
        chaninfoclassname = class(obj.List{i}.ChanInfos{j});
        thiscol = FileList.whichcolumn('ChanInfoClassName', headers);
        sheet_summary(thisrow, thiscol) = {chaninfoclassname};
        
        for k = 1:length(chanpropnames)
            thispropname = chanpropnames{k};
            chanpropvals{k} = obj.List{i}.ChanInfos{j}.(thispropname);
            
            val = chanpropvals{k};
            
            if isempty(val)
                continue;
            else
                
                if all(~fileListHeaders.ismemberOfHeaders(thispropname)) && isempty(additionalHeaders)
                    % additional to the current headers
                    % automatically add any properties that are not included
                    % in the curret headers
                    
                    fileListHeaders = fileListHeaders.appendHeaders({thispropname});
                    headers = fileListHeaders.Headers;
                    sheet_summary(row_h, 1:length(headers)) = headers; %TODO
                end
                
                if isstruct(val)
                    % TODO not supported
                    if ~strcmp(thispropname, 'Header')
                        warning ('Values %s in struct format is not supported by xlswrite', thispropname);
                    end
                elseif ~isscalar(val) && iscell(val)
                    % TODO not supported
                    warning ('Values %s in cell array format is not supported by xlswrite', thispropname);
                    
                elseif ~isscalar(val) && isnumeric(val)
                    % xlswrite does not support character array (val must be a single line)
                    
                    %% Convert numeric array into single line comma separated values in a char row
                    % example:
                    % val =  [1, 2, 3; 10, 100, 1000];
                    % is converted into...
                    % val =
                    %    1.000000,    2.000000,    3.000000; 10.000000,  100.000000, 1000.000000;
                    
                    valcellstr = regexprep(cellstr(num2str(val, '%f, ')), '(,$)', '; ');
                    val = horzcat(valcellstr{:}); % char type row
                    
                    thiscol = FileList.whichcolumn(thispropname, headers);
                    if ~isempty(thiscol)
                        if ~iscell(val)
                            val = {val};
                        end
                        
                        sheet_summary(thisrow, thiscol) = val;
                    else
                        error('K:FileList:saveSummaryXlsx:thiscol:empty',...
                            'Could not find an item corresponding to %s in headers', thispropname);
                    end
                    
                elseif isnumeric(val) && isscalar(val) ||...
                        iscell(val) && isscalar(val) ||...
                        ischar(val) && isrow(val)
                    
                    % OK
                    thiscol = FileList.whichcolumn(thispropname, headers);
                    
                    if ~isempty(thiscol)
                        if ischar(val) && isrow(val) || isnumeric(val)&& isscalar(val)
                            val = {val};
                        end
                        
                        sheet_summary(thisrow, thiscol) = val;
                        
                    else
                        error('K:FileList:saveSummaryXlsx:thiscol:empty',...
                            'Could not find an item corresponding to %s in headers', thispropname);
                    end
                end
            end
        end
    end
end


%% Sort

% sort columns
if length(headers_def) < length(headers)
    [~, I] = sort(sheet_summary(row_h, length(headers_def)+1:end));
    A = sheet_summary(row_h:end, length(headers_def)+1:end);
    sheet_summary(row_h:end, length(headers_def)+1:end) = A(:, I);
    clear A I
end


% sort rows

sheet_summary(row_h+1:end, :) = sortrows(sheet_summary(row_h+1:end, :), [2, 3]); %TODO



s = warning('off', 'MATLAB:xlswrite:AddSheet'); % supress the warning of adding sheet
[status, message] = xlswrite(fullfile(dest, 'summary.xlsx'), sheet_summary, 'summary', 'A1');
if status~= 1
    error(message);
end
warning(s.state, s.identifier); % put the warning back
clear s

% export(hospital,'XLSFile','hospital.xlsx')
% http://www.mathworks.co.uk/help/stats/export-dataset-arrays.html
% http://www.mathworks.co.uk/help/matlab/import_export/exporting-to-excel-spreadsheets.html
%
% www.mathworks.co.uk/help/matlab/matlab_external/work-with-microsoft-excel-spreadsheets-using-net.html
end