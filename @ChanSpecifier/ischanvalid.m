function [TF, names] = ischanvalid(chanSpec, chanfields, func, varargin)
% ChanSpecifier.ischanvalid determines if the powers of specific channels
% in chanSpec satisfies condition func.
%
% [TF, names] = ischanvalid(chanSpec)
% [TF, names] = ischanvalid(chanSpec, chanfields, func)
% [TF, names] = ischanvalid(chanSpec, chanfields, func, TFchan)
% [TF, names] = ischanvalid(chanSpec, 'gui')
% [TF, names] = ischanvalid(chanSpec, 'gui', TF)
%
%
% INPUT ARGUMENTS
% chanSpec      A ChanSpecifier object
%
% chanfields    Cell vector of fieldnames or char row string of a fieldname of channels
%               that are to be used for evaluation.
%               if these chanfields do not exist in the channels, it will result in an error.
%
% 'gui'         You can 'gui' as the second input variable for
%               interactively selecting channels.
%
% func          A function handle for a function that returns scalar logical.
%               For each channels that are specified by 
%
% TFchan        (Optional) A logical column vector with the length sum(chanSpec.ChanNum)
%               Any channels that are not specified by TFchan will be marked as false in output TF.
%               
%                   'all'       (default) to include all the channels
%                   'gui'      %TODO
%
%                   'eeg'       only EEG channels*
%                   'spike'     only uinte/probeA00e channels*
%                   'lfp'       only LFP channels (probeA00 or probeA00h)*
%                   * Only for ChanSpecifier_thalamus subclass objects
%
% % [TF, names] = ischanvalid(chanSpec, 'gui', TF)
%               In this syntax, the logical index TF as input allows you to
%               select initial selection of channels in the listdlg dialog.
%
%
% OUTPUT ARGUMENTS
% TF            A logical column vector with the length sum(chanSpec.ChanNum).
%               Logical values for channels included in .mat files stored
%               in chanSpec object.
%               %TODO NOTE this format does not support an empty .mat file
%               that does not contain any channel in it. In other words,
%               you cannot select the empty .mat files with this method.
%
% names         In order to tell which value is which, this cell array
%               column of strings has the same size as TF. It contains name
%               of each .mat files and title of each channel that
%               corresponds to the TF. Use names(TF) to get the names of
%               selected mat files and channels.
%
% EXAMPLES
%
%      [TF, names] = ischanvalid(chanSpec, 'title', @(x) ismatchedany(x, 'probeA03e'))
%      [TF, names] = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'probeA03e'))
%
% Choose channel whose "location" is SNr or SNc
%      [ischan_SNrOrSNc, names] = chanSpec.ischanvalid('location', @(x) ismatchedany(x, 'SNr|SNc')');
%
% mat files that contain SNr/SNc
%      ismat_SNrOrSNc = chanSpec.ismatvalid(ischan_SNrOrSNc);
%
% Choose EEG chan
%      ischan_EEG = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'EEG|IpsiEEG')');
%
% Choose event channels whose "title" end with "e"
%      ischan_probeA00e = chanSpec.ischanvalid('title', @(x) ismatchedany(x, 'probe[AB]\d\de')');
%      ischan_probeA00e = chanSpec.ischanvalid('chantype', @(x) strcmp(x, 'event'));
%
% mat files of 6-OHDA animals
%      ismat_6OHDA = chanSpec.ismatvalid(chanSpec.ischanvalid('dopamine', @(x) ismatchedany(x, '6-OHDA')'));
%
% mat files of Dopamine intact animals
%      ismat_Intact = chanSpec.ismatvalid(chanSpec.ischanvalid('dopamine', @(x) ismatchedany(x, 'Intact')')); 
%      ismat_Intact = ~ismat_6OHDA;
%
% Find channels whose EEG power satisfies criteria
% TF = isPpowerValid(chanSpec, 'eeg', @(x, y) x < 0.4 && y < 0.4, 'powerSlow', 'powerDelta')
%
% See also
% ChanSpecifier


TF = false(sum(chanSpec.ChanNum), 1);

names = chanSpec.ChanTitlesMatNamesAll;
mch = cellfun(@(x,y) ['(',num2str(x),',',num2str(y),') '],names(:,1),names(:,3),...
    'UniformOutput',false);
names = arrayfun(@(x) [mch{x,1},names{x,2},' | ',names{x,4}], (1:size(names,1))',...
    'UniformOutput',false);

narginchk(1, 4);

if nargin == 1
    TF(:) = true;
    return
    
elseif nargin == 2
    
    if strcmpi(chanfields, 'gui')
        
        [TF,names] = local_listdlg(names, 1:length(names),TF);

        return;
        
    else
       
        error('ischanvalid:gui:nargin:invalid',...
            'when nargin == 2 you must use the syntax: ischanvalid(chanSpec, ''gui'') ')
    end
    
elseif nargin == 3 && ischar(chanfields) && strcmpi(chanfields, 'gui')
    
    assert(iscolumn(func) && all(func == 1 | func == 0),...
        ['ischanvalid:TF:invalid:format','in the syntax "ischanvalid(obj,''gui'',TF)", ',...
        'the TF variable must be column of 0 or 1'])
    
    assert(length(func) == sum(chanSpec.ChanNum),'ischanvalid:TF:invalid:length',...
        'TF must have the length that equals to the sum of chanSpec.ChanNum')
    tf = func; 
    
    index = find(tf)';
    
    [TF,names] = local_listdlg(names,index,TF);

    return;
    
    
end


p = inputParser;
p.addRequired('chanSpec', @(x) isa(x, 'ChanSpecifier'));
p.addRequired('chanfields', @(x) ischar(x) && isrow(x) || isvector(x) && iscellstr(x));
p.addRequired('func', @(x) isscalar(x) && isa(x, 'function_handle'));
p.addOptional('TFchan', 'all', @(x) isscalar(x) && ismember(lower(x), {'all', 'gui', 'eeg', 'spike', 'lfp'}) ...
    || iscolumn(x) && length(x) == sum(chanSpec.ChanNum) && all(x == 0 & x == 1));

p.parse(chanSpec, chanfields, func, varargin{:});

TFchan = p.Results.TFchan;
TFchan = local_prepTFchan(chanSpec, TFchan);

if ischar(chanfields)
    chanfields = {chanfields};
end

if isrow(chanfields)
    chanfields = chanfields';
end

%% job
n = length(chanfields);
    
assert(nargin(func) == n, 'ischanvalid:chanfields:badnumber',...
    'The number of field variables %d do not match func"s requirement %d.',...
    n, nargin(func));

k = 0;

if chanSpec.MatNum > 0
        
    for m = 1:chanSpec.MatNum % mat files
        
        chantitles = chanSpec.ChanTitles{m};
        
        for ch = 1:chanSpec.ChanNum(m)
        
            k = k + 1;
 
            if ~TFchan(k)
                TFthis = false;
                continue;
            end     
        
            vals = cell(1, n);
            for f = 1:n
                try
                    vals{f} = chanSpec.List(m).channels.(chantitles{ch}).(chanfields{f}); %TODO
                catch Mexc1
                   if strcmp(Mexc1.identifier,'MATLAB:nonExistentField')
                       break
                   else
                       throw(Mexc1);
                   end
                end
            end
            clear f
            
            if exist('Mexc1','var')
                clear Mexc1
                TFthis = false;
                continue; 
            end
        
            try
                TFthis = func(vals{:});
                
            catch Mexc1
                dbstop if error
                throw(Mexc1);
            end
            
            assert(TFthis == 0 || TFthis == 1,...
                'ischanvalid:func:output','Output of func must be either 1 or 0 (scalar).');
        
            if TFthis
            
                %TODO
%                 validmatnamefull = chanSpec.MatNamesFull{m};
%             
%                 validmatnamefull = strrep(validmatnamefull, '\', '\\');
%                 validmatnamefull = strrep(validmatnamefull, '.', '\.');
%             
%                 thisTFvec = chanSpec.ismatnamematched(validmatnamefull, 'full'); 
                
                TFthisvec = false(sum(chanSpec.ChanNum), 1);
                TFthisvec(k) = true;
                
                TF = TF | TFthisvec;
            end
        
        end
        
    end

else

    TF = []; % this should be handled separately

end

end

%--------------------------------------------------------------------------

function TFchan = local_prepTFchan(chanSpec, TFchan)

%% prep TFchan

switch lower(TFchan)
    case 'all'
        TFchan = true(sum(chanSpec.ChanNum), 1);             
    
    case 'eeg'
        assert(isa(chanSpec, 'ChanSpecifier_thalamus'));
        
        TFchan = chanSpec.ischan_EEG;
        
    case 'spike'
        assert(isa(chanSpec, 'ChanSpecifier_thalamus'));
        
        TFchan = chanSpec.ischan_unite | chanSpec.ischan_probeA00e; 
    case 'lfp'
        assert(isa(chanSpec, 'ChanSpecifier_thalamus'));

        TFchan = chanSpec.ischan_probeA00h; % probeA00 or probeA00h

    otherwise
end

end

%--------------------------------------------------------------------------

function [TF,names] = local_listdlg(names,index,TF)



[answer,OK] = listdlg('PromptString','Select files / channels:',...
    'SelectionMode','multiple',...
    'ListString',names, 'ListSize', [300, 300], 'InitialValue', index);

if ~OK
    disp('Cancelled by User');
    
    TF = [];
    names = {};
    
end

TF(answer) = true;



end