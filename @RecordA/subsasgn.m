function varargout = subsasgn(this, S, input)
% varargout = subsasgn(this, S, input)
%
% based on subsasgn for MATLAB tscollection class

if strcmp(S(1).type,'.') && any(strcmp(S(1).subs, this.ChanTitles))
    % this.chantitle1
    %
    %TODO how to implement ('name') notation instead???
    if length(S)>=2 % .Chans.Prop =
        %example: this.testWF.Data(1:100) = ones(100, 1)
        
        % create a Chan objects
        
        ind = strcmp( S(1).subs, this.ChanTitles);
        thischan = this.Chans{ind}; % only builtin subsref is available
        % OK
        
        % thists = getts(this,S(1).subs);
        
        thischan = subsasgn(thischan, S(2:end), input);
        
        % update Chans
        
        this.Chans{ind} = thischan;
        varargout{1} = this;
        
        % OK 14/02/2014 21:35
        
    else % .Chans =
        varargout{1} = setts(this,input,S(1).subs); %TODO
    end
    
elseif any(strcmpi(S(1).subs, {'Name','Chans','Start','SRate'}))
    if length(S)>=2
        pname = S(1).subs;
        input = subsasgn(this.(pname), S(2:end), input);
        this.(pname) = input;
        varargout{1} = this;
        
        %example:
        % rec = Record({E, W}, 'Name','hogehogehoge');
        % rec.RecordTitle(1:4) = 'HOGE' %OK 14/02/2014 22:43
    else
        pname = S(1).subs;
        this.(pname) = input;
        varargout{1} = this;
        
        %example:
        % rec = Record({E, W}, 'Name','hogehogehoge');
        % rec.RecordTitle(1) = 'H' %OK 14/02/2014 22:49
    end
    
    %     %% New member timeseries
    % elseif length(S)== 1 && strcmp(S.type,'.') && ischar(S.subs) && ...
    %         isa(input,'timeseries')
    %     input.RecordTitle = S.subs;
    %     varargout{1} = addts(this,input);
else
    try
        [varargout{1:nargout}] = builtin('subsasgn', this, S, input);
    catch ME1
        dbstop if error
        error('KOUICHI:Record:subsasgn:badsyntax', ...
            'Invalid syntax for subasgn')
    end
end

end