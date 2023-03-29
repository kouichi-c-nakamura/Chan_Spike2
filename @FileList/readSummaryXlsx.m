function obj = readSummaryXlsx(obj, xlsxpath)
%
% src
%
% TODO When reading, you cannot get which subclass of ChanInfo to call
%




[~,~,sheet_summary] = xlsread(fullfile(xlsxpath, 'summary.xlsx'), 'summary');



if strcmpi(sheet_summary{1, 1}, 'ListName:')
    
    obj.ListName = sheet_summary{1, 2};
else
    error('K:FileList:readSummaryXlsx:ListName:nomatch',...
        '''ListName:'' was not found in sheet_summary');
end


if strcmpi(sheet_summary{2, 1}, 'Date:')
    
    obj.ListName = sheet_summary{2, 2};
else
    error('K:FileList:readSummaryXlsx:Date:nomatch',...
        '''Date:'' was not found in sheet_summary');
end

if strcmpi(sheet_summary{3, 1}, 'Time:')
    
    obj.ListName = sheet_summary{3, 2};
else
    error('K:FileList:readSummaryXlsx:Date:nomatch',...
        '''Time:'' was not found in sheet_summary');
end


if strcmpi(sheet_summary{4, 1}, 'Comment:')
    
    obj.ListName = sheet_summary{4, 2};
else
    error('K:FileList:readSummaryXlsx:Comment:nomatch',...
        '''Comment:'' was not found in sheet_summary');
end


%% support subclass of FileList class
tf = cellfun(@isempty, sheet_summary(5, :));
if any(tf)
    for i = 1:2:find(tf, 1, 'last')
        
        val = obj.(sheet_summary{5, i+1});
        
        val = recoverDelimitedCharIntoArray(val);
        
        try
            obj.(sheet_summary{5, i}) = val;
        catch ME1
            warning(ME1);
        end
        
    end
end

row_h = 6;

headers = sheet_summary(row_h, :);
headers = regexprep(headers, '\s\[\w*\]$', '');

thisrow = row_h;
rows_chaninfo = size(sheet_summary(row_h + 1:end, :), 1);

col_ChanInfoClassName = FileList.whichcolumn('ChanInfoClassName', headers);

col_RecordTitle = FileList.whichcolumn('RecordTitle', headers);


for i = 1:rows_chaninfo
    thisrow = thisrow + 1;
    
    thisRecordTitle = sheet_summary{thisrow, col_RecordTitle};
    if isnan(thisRecordTitle)
        thisRecordTitle = '';
    end
    
    
    if isempty(obj.List)
        ismemberRecordTitle = false;
    else
        ismemberRecordTitle = ismember(thisRecordTitle ,{obj.List{:}.RecordTitle});
    end
    
    
    if ~ismemberRecordTitle % new RecordInfo
        obj = obj.addRecord(RecordInfo('Name', thisRecordTitle));
    end
    
    recInfoN = ismember({obj.List{:}.RecordTitle}, thisRecordTitle);
    
    classname = sheet_summary{thisrow, col_ChanInfoClassName};
    ChanInfo_h = str2func(classname); % function handle for constructor
    
    % prepare and add an empty object to the RecordInfo
    thisChanInfo = ChanInfo_h();
    
    
    for j = 1:size(sheet_summary, 2)
        
        thisprop =  headers{j};
        thiscol = FileList.whichcolumn( thisprop, headers);
        
        val = sheet_summary{thisrow, thiscol};
        
        if isprop(thisChanInfo, thisprop)
            if ~isnan(val)
                if isstruct(thisChanInfo.(thisprop))
                    % TODO struc type is not supported yet
                    continue
                elseif isscalar(thisChanInfo.(thisprop)) && isnumeric(thisChanInfo.(thisprop))
                    if isscalar(val) && isnumeric(val)
                        try
                            thisChanInfo.(thisprop) = val;
                        catch ME1
                            if ~strcmp(ME1.identifier,  'MATLAB:class:SetProhibited')
                                keyboard
                            end
                            
                        end
                    else
                        warning('K:FileList:readSummaryXlsx:numericscalarprop',...
                            'The default value of the property ''%s'' is sclalar numeric type but the value from the Excel file was not in the format', thisprop);
                    end
                elseif  ischar(thisChanInfo.(thisprop))
                    if  ischar(val) && isrow(val) && isempty(thisChanInfo.(thisprop)) % TODO not sure
                        if nnz(strfind(val, ',')) == 0
                            % char type
                            try
                                thisChanInfo.(thisprop) = val;
                            catch ME1
                                if ~strcmp(ME1.identifier,  'MATLAB:class:SetProhibited')
                                    keyboard
                                end
                            end
                            
                        elseif nnz(strfind(val, ',')) > 0
                            % char type for numeric array
                            
                            
                            try
                                thisChanInfo.(thisprop) = val;
                            catch ME1
                                if ~strcmp(ME1.identifier,  'MATLAB:class:SetProhibited')
                                    keyboard
                                end
                            end
                            
                        else
                            warning('K:FileList:readSummaryXlsx:charinvalid',...
                                'The default value of the property ''%s'' is char type but the value from the Excel file was not in the format', thisprop);
                        end
                    end
                    
                end
                
                
                
            end
        end
        
        % TODO
        % how to recover each properties???
        % in particular Path, and Header
        
        % TODO convert the relative path to abs path
        
        
    end
    obj.List{recInfoN} = obj.List{recInfoN}.addChan(thisChanInfo); % TODO class changes;
    %TODO syntax error; because they are not handle object!
    
end

end



function val = recoverDelimitedCharIntoArray(val)
%TODO judge if the values are delimited





end