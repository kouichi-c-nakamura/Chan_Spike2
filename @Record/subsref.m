function varargout = subsref(this,S)
% varargout = subsref(this,S)
%
% S     structure (try "doc substruct" for more detail)
%       S.type    either '.', '()', or '{}'
%       S.subs    subscript values (field name or cell array of index vectors)
%
% You can use dot notation to refer to specific element of Chans as
% follows:
%
% this.ChanTitle        ... may have conflicts with property names!!!
% this.ChanTitle.propertyname
% this.ChanTitle.propertyname(a.b)
% this.ChanTitle.methodname(a,b,c, ...)
%
% this.('Chan Title')  ... allowing the use of a space in the ChanTitle
% this.('Chan Title').propertyname
% this.('Chan Title').propertyname(a,b)
% this.('Chan Title').methodname(a,b,c, ...)
%
%
% NOTE:
% this.property{:}
% doesn't work properly due to a known serious bug.
% http://www.mathworks.com/matlabcentral/answers/57562-subsref-overload-has-fewer-outputs-than-expected-on-cell-attribute
%
%
% See Also Record


switch S(1).type
    case '.'
        switch S(1).subs
            case this.ChanTitles %OK 18/06/2013
                %example: this.('testWF')
                %example: this.testWF
                %example: this.('testWF').SRate
                %example: this.testWF.Length
                %
                %
                % These are special reference syntax fo Record
                
                %% Access to a child of Chans
                
                ind = strcmp( S(1).subs, this.ChanTitles);
                AA = this.Chans{ind};
                
                if length(S) == 1
                    %example: this.('testWF')
                    %example: this.testWF
                    
                    varargout{1} = AA;
                    return;
                else
                    %example: this.('testWF').SRate
                    %example: this.testWF.Length
                    
                    [varargout{1:nargout}] = builtin('subsref', AA, S(2:end));
                    
                    return
                end

                
            otherwise
                %example: this.SRate, this.MaxTime
                %example: this.MaxTime(1)
                %example: this.plot
                
                if any(ismember(S(1).subs, {'Chans', 'ChanTitles'})) ...
                        && length(S) >= 2 ...
                        && strcmp(S(2).type, '{}') ...
                        && iscell(S(2).subs)
                    if isa(S(2).subs{1,1}, 'char') 
                        %example: this.Chans{:}
                        %    
                        % http://www.mathworks.com/matlabcentral/answers/57562-subsref-overload-has-fewer-outputs-than-expected-on-cell-attribute
                        
                        error('K:Record:subsref:BadSubscript',...
                            ['Known bug of MATLAB subsref, cell and colon\ninstance.some_cell{:}\n'...
                            '<a href="http://www.mathworks.com/matlabcentral/answers/57562-subsref-overload-has-fewer-outputs-than-expected-on-cell-attribute">subsref overload has fewer outputs than expected on cell attribute</a>']);
                        
                    elseif isnumeric(S(2).subs{1,1}) && ~isscalar(S(2).subs{1,1}) 
                        %example: this.Chans{1:2}
                        
                        error('K:Record:subsref:BadSubscript2',...
                            'Multiple reference with non scalar indices to the field %s with {} is not accepted.',...
                            S(1).subs);
                    end
                end
                
                if length(S) == 2 && isempty(S(2).subs) %TODO not sure
                    S(2).subs = {1};
                end
                [varargout{1:nargout}] = builtin('subsref', this, S); % default behaviour
        end
    otherwise
        
        
        [varargout{1:nargout}] = builtin('subsref', this, S); % default behaviour
        
end


