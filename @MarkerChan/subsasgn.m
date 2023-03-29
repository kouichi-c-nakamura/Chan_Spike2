function varargout = subsasgn(obj, S, input)
% varargout = subsasgn(obj, S, input)
%
% hack dataset.subsasgn to allow the syntax obj.MarkerFilter(2:5,1) = [1 ;
% 0; 1; 1], which is not possible for dataset by default.
%
%TODO
% This customization is making the class difficult to use.
% Consider giving up all above syntax. Just use normal Table operation is
% better.


if strcmp(S(1).type,'.')
    if any(strcmp(S(1).subs, 'MarkerFilter'))
        if length(S) == 2
            if strcmp(S(2).type,'()') && iscell(S(2).subs) &&  all(cellfun(@(x) isnumeric(x) || isequal(x ,':'), S(2).subs))

                % example: obj.MarkerFilter(2:5,1) = [1 ; 0; 1; 1]
                
                %% parse
                p = inputParser;
                
                vf_input = @(x) islogical(x) || ...
                    ( isnumeric(x) && all(x(x~=0) == 1) ) ||...
                    (ischar(x) && any(strcmpi(x, {'show','hide'})));
                
                addRequired(p, 'input', vf_input );
                parse(p, input);
                
                %% job
                
                mFiltTF = table2array(obj.MarkerFilter);
                clear mFiltCellHeader
                
                rows = S(2).subs{1};
                cols = S(2).subs{2};
                
                if ischar(input)
                    switch lower(input)
                        case 'show'
                            input = true(length(rows), length(cols));
                        case 'hide'
                            input = false(length(rows), length(cols));
                    end
                    
                elseif isnumeric(input) && ~isempty(input)
                    input = logical(input);
                elseif isempty(input)
                    input = true(length(rows), length(cols));
                elseif ~islogical(input)
                    error('K:Chan:MarkerChan:subsasgn:input:invalid',...
                        'input is invalid');
                end
                
                mFiltTF(rows, cols) = input;
                obj.MarkerFilter = mFiltTF;
                
                varargout{1} = obj;
                
            else
                % exmaple: obj.MarkerFilter{'code1', 'mask0'} = false
                
                if isequal(input,'hide')
                    input = false;
                elseif isequal(input,'show')
                    input = true;
                end 
                
                obj.MarkerFilter = subsasgn(obj.MarkerFilter, S(2), input);
                varargout{1} = obj;
                
                
            end
            
        elseif length(S) == 1
            % example:
            %  obj.MarkerFilter = [];
            %  obj.MarkerFilter = 'show';
            %  obj.MarkerFilter = 'hide';
            %  obj.MarkerFilter = X;
            
            if ischar(input)
                if strcmpi(input, 'show')
                    input = true(256,4);
                elseif strcmpi(input, 'hide')
                    input = false(256,4);
                end
            end
            
            obj.MarkerFilter = input;
            varargout{1} = obj;
            
        else
            % probably end up in error
            obj.MarkerFilter = subsasgn(obj.MarkerFilter, S(2:end), input);
            varargout{1} = obj;
            
        end
        
    elseif any(strcmp(S(1).subs, properties(obj)))
        pname = S(1).subs;
        
        if length(S)>=2
            if strcmpi(pname,'MarkerCodes')
                input = subsasgn(table2array(obj.(pname)), S(2:end), input);
                
            else
                
                input = subsasgn(obj.(pname), S(2:end), input);
                
            end
            obj.(pname) = input;
            varargout{1} = obj;

            
        else
            obj.(pname) = input;
            varargout{1} = obj;
        end
        
    else
        error('K:Chan:MarkerChan:subsasgn:input:invalid',...
            'input uses invalid subscript assignment syntax');
    end
    
elseif strcmp(S(1).type,'()')
    error('K:Chan:MarkerChan:subsasgn:input:invalid',...
        'input uses invalid subscript assignment syntax');
    
elseif strcmp(S(1).type,'{}')
    error('K:Chan:MarkerChan:subsasgn:input:invalid',...
        'input uses invalid subscript assignment syntax');
else
    error('K:Chan:MarkerChan:subsasgn:input:invalid',...
        'input uses invalid subscript assignment syntax');
end

end