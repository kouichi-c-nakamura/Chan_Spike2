function [ output_args ] = importMasterXlsx(obj, xlsxpath, chan_subclassname )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here



narginchk(3, 3);

p = inputParser;

vf_xlsxpath = @(x) ischar(x) && isrow(x) && ~isempty(x);

addRequired(p, 'xlsxpath', vf_xlsxpath);

vf_chan_subclassname = @(x) ischar(x) && isrow(x) && ~isempty(x);

addRequired(p, 'xlsxpath', vf_xlsxpath);


%% open an Excel.xlsx file (a master file that containing additional information about rec) at xlsxpath with xlsread


[num, txt, sheet_master] = xlsread(xlsxpath); % TODO need to specify the format of the master.xlsx!!!


tf = cellfun(@isempty, sheet_master(5, :));
if any(tf)
    for i = 1:2:find(tf, 1, 'last')
        
        val = obj.(sheet_master{5, i+1});
        
        val = recoverDelimitedCharIntoArray(val);
        
        try
            obj.(sheet_master{5, i}) = val;
        catch ME1
            warning(ME1);
        end
        
    end
end




%% Construct Chan subclass specified with chan_subclassname

% TODO how to use constructor with its name string??? It is possible at
% all?


for i = 1:length(obj.List)
    recTitle = obj.List{i}.RecordTitle;
    
    for j = 1:length(obj.List{i}.ChanInfos)
        
        %% get ChannelTitle
        thisrow = thisrow + 1;
        
        if ~isempty(recTitle)
            sheet_summary(thisrow, 1) = recTitle;
            clear pos
        end
        
        %% ChanInfo
        chanprops = obj.List{i}.ChanInfos{j}.get;
        
        
        %% support subclass of ChanInfo %TODO
        
        chanpropnames = fieldnames(chanprops);
        chanpropvals = cell(length(chanpropnames), 1);
        
        %% get ChanIinfoClassName
        
        chaninfoclassname = class(obj.List{i}.ChanInfos{j});
        thiscol = whichExcelColumn('ChanInfoClassName', headers);
        sheet_summary(thisrow, thiscol) = {chaninfoclassname};
        
        for k = 1:length(chanpropnames)
            thispropname = chanpropnames{k};
            chanpropvals{k} = obj.List{i}.ChanInfos{j}.(thispropname);
            
            val = chanpropvals{k};
            
            if isempty(val)
                continue;
            else
                
                if ~fileListHeaders.ismemberOfHeaders(thispropname) && isempty(additionalHeaders)
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
                    
                    thiscol = whichExcelColumn(thispropname, headers);
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
                    thiscol = whichExcelColumn(thispropname, headers);
                    
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










end

