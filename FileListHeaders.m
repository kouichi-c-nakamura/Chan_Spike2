classdef FileListHeaders
    %FileListHeaders 
    % provides format restrction for headers in Excel worksheet
    % Use this class with FileList class
    %
    % 1. Each element of headers must be unique
    %
    % 2. Header title itself cannot include a space, becuase it corresponds
    % to property name of Chan class or its subclasses
    %
    % 3. You can add measuring unit with square brackets following a space
    % like 'Start [sec]'. The measuring unit is ignored when validating the
    % uniquness of header elements.%
    %
    % 4. You cannot delete the default header elements
    
    properties (SetAccess = protected)
        Headers = {'RecordTitle', 'ChanNumber', 'ChanTitle',  'Path', 'ChanStructVarName','ChanInfoClassName' ...
            'DataUnit', 'TimeUnit', 'Start [sec]', 'MaxTime [sec]', 'SRate [Hz]','SInterval [sec]',...
            'Length', 'Header', 'ChanTitleRef', 'PathRef', 'ChanStructVarNameRef'}
    end
    
    methods
        function obj = FileListHeaders(headers)
            % obj = FileListHeaders()
            %
            % obj = FileListHeaders(headers)    
            % importing from an Excel file or customized (ie.e using 
            % subclasses of Chan class) Record objects
            
            narginchk(0, 1);
            
            switch nargin
                case 0
                    return
                    
                case 1
                    % make sure headers contains all the default elements
                    
                    assert(iscellstr(headers) && isrow(headers),...
                        'K:FileListHeaders:headers:notcellstrrow',...
                        'headers must be row vector of cellstr');
                    
                    [Lia, ~] = ismemberOfHeaders (obj, headers); 
                    
                    assert(all(Lia), ...
                        'K:FileListHeaders:headers:notalldefaultheaders',...
                        'headers must include all the default members of Headers property');
                    
                    FileListHeaders.assertCoreTextUniqAndNotContainingSpace(headers);
                    
                    additionalh = setdiff(headers, obj.Headers); % additionalh is in sorted order

                    obj.Headers = [obj.Headers, additionalh];
                    
            end
        end
        
        function obj = appendHeaders(obj, newheaders)
            % obj = appendHeaders(obj, {'header1', 'header2 [mV]'})
            %
            % You can add unique Headers item with a measuring unit.
            % 1. The actual name cannot include a space.
            % 2. Optinal Measuring unit must be separated from the name by a space
            % 3. Optional Measuring unit must be placed between a pair of
            % square brackets.
            
            assert(  isrow(newheaders) && iscellstr(newheaders) || ischar(newheaders),...
                'K:FileListHeaders:appendHeaders:newheaders:notcellstrrow',...
                'newheaders must be row vector of cellstr or a row of char type');
            
            if ischar(newheaders)
                newheaders = {newheaders};
            end
                        
            newheaders = [obj.Headers, sort(newheaders)];
            
            FileListHeaders.assertCoreTextUniqAndNotContainingSpace(newheaders);

            obj.Headers = newheaders;
            
        end
        
        function obj = deleteHeaders(obj, delheaders)
            % obj = deleteHeaders(obj, delheaders)
            %
            % delheaders     Cell array of strings.  
            %
            % You can delete obj.Headers elements:
            % 1. If all the memebrs of delheaders are members of obj.Headers
            % 2. And if all the memebrs of delheaders are not included in
            % default Headers memebrs.
            
            assert(iscellstr(delheaders) && isrow(delheaders),...
                'K:FileListHeaders:deleteHeaders:delheaders:notcellstrrow',...
                'delheaders must be row vector of cellstr');
            
            coreh = regexprep(obj.Headers, '\s\[\w*\]$', '');
            coredelheaders = regexprep(delheaders, '\s\[\w*\]$', '');
            
            assert(all(ismember(coredelheaders, coreh)),...
                'K:FileListHeaders:deleteHeaders:delheaders:notmember',...
                'Elements of delheaders must be member of obj.Headers');
            
            defaultobj = FileListHeaders();
            defh = defaultobj.Headers;
            
            assert(~all(ismember(delheaders, defh)),...
                'K:FileListHeaders:deleteHeaders:delheaders:ismember of default headers',...
                'You can not delete default members of Headers property.');           
            
            [~, ia] = setdiff(coreh, coredelheaders);
            h = obj.Headers;
            remaining = h(ia);
            
            newheaders = [defh, setdiff(remaining, defh)];
            
            obj.Headers = newheaders;
                        
        end
        
        function [Lia, Locb] = ismemberOfHeaders(obj, newheaders)
            % [Lia, Locb] = ismemberOfHeaders(obj, newheader)
            % [Lia, Locb] = ismemberOfHeaders(obj, {'newheader1', 'newheader2 [mV]')
            %
            % returns if newheaders are elements of obj.Headers except the
            % measuring units in squared brackets
            
            assert(isrow(newheaders) && iscellstr(newheaders) || ischar(newheaders),...
                'K:FileListHeaders:ismemberOfHeaders:newheader:invalid',...
                'newheader must be row vector of cellstr or a row of char type');

            if ischar(newheaders)
                newheaders = {newheaders};
            end
            
            %% remove measuring unit such as ' [mV]' at the end
            newheaderCore = regexprep(newheaders, '\s\[\w*\]$', '');
            headersCore = regexprep(obj.Headers, '\s\[\w*\]$', '');
            
            [Lia, Locb] = ismember(headersCore, newheaderCore);

            
        end
        
        
    end
    methods (Static)
        
        function assertCoreTextUniqAndNotContainingSpace(headers)
            % core text of headers cannot contain a space expcet for one
            % before measuring unit in square brackets.
            
            assert(iscellstr(headers) && isrow(headers),...
                'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:headers',...
                'headers must be a row vector of cellstr')
            
            headersCore = regexprep(headers, '\s\[\w*\]$', ''); %% remove measuring unit such as ' [mV]' at the end
            
            assert(all(cellfun(@isempty, regexp(headersCore, '\s', 'ONCE'))),...
                'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:containingspace',...
                'Elements of headers cannot contain a space expcet for one before measuring unit in square brackets.');
            
            assert(all(cellfun(@isempty, regexp(headersCore, '[\[\]]', 'ONCE'))),...
                'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:containinsqbrckt',...
                'Elements of headers cannot contain a square bracket expcet for measuring unit.');            
            
            assert(all(cell2mat(regexp(headersCore, '^\w*$', 'ONCE'))),...
                'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:notjustword',...
                'Elements of newheaders must be one word expcet for one before measuring unit in square brackets.');
            
            % check uniqueness
            
            assert(length(unique(headersCore)) == length(headersCore),...
                'K:FileListHeaders:assertCoreTextUniqAndNotContainingSpace:headers:notunique',...
                'Elements of headers must contain unique names');
        end
        
        
    end
    

    
    
end

