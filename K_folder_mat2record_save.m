function [list, h] = K_folder_mat2record_save(srcdir, destdir, suffix)
% [list, h] = K_folder_mat2record_save(srcdir, destdir, suffix)
%
% srcdir     folder path for input .mat files that were from Spike2 (required)
% destdir    folder path for output .mat files containing Chan
%             objects (required)
%
%(Options)
% suffix      string for suffix to be added output .mat files (optional)
%
% list        cell array containing the list of data
% h           header for the list cell array
%             Name
%             srcdir
%             destdir
%             Start
%             MaxTime
%             Duration
%             SRate
%             SInterval
%             ChanTitles
%
% EXAMPLE
% srcdir = 'Z:\Work';
% destdir = 'Z:\Work\test'
% [list, h] = K_folder_mat2record_save(srcdir, destdir, '_chan')
%
%
%% NOTE
% 
% Saving recording data in custom class (Record) is highly risky and should
% be avoided.
%
%% NOTE
%
% The constructor of Record class now supports a mat file name as an input
% argument.
%
% rec = Record(matfilename)
%
%
% The constructor of FileList class supports a folder path or cell array of
% names of mat files as an input argument.
%
% obj = FileList(folderpath)
% obj = FileList(matfilenames)
%
% See also
% Record, FileList

%% Parse input
narginchk(2,3);
if ~isdir(srcdir)
   error('K:K_folder_mat2record_save:srcdir', 'srcdir is not a valid folder'); 
end

if ~isdir(srcdir)
   error('K:K_folder_mat2record_save:destdir', 'destdir is not a valid folder'); 
end

if exist('suffix', 'var') &&  ~ischar(suffix)
   error('K:K_folder_mat2record_save:suffix', 'suffix is not char class'); 
end

% Param/Value pairs


%% job

curr = what;

cd(srcdir)
listing = dir('*.mat');
mnames = {listing.name}';

list = cell(length(mnames), 8);


for i_mat=1:length(mnames)
    name = mnames{i_mat};
    name_ = name(1:strfind(name, '.mat')-1); % name without '.mat'
    
    S = load(fullfile(srcdir, name));
    
    chantitles = fieldnames(S);
    
    validateS(S);
    
    %% job: convert Spike2 .mat into Chan objects
    
    rec = Record('Name', name_);
    
    for j = 1:length(chantitles)
        
        this = S.(chantitles{j});
        header = rmfield(this, {'values'});
        
        % Judge data type by looking at struct content
        if ~all(this.values == 0 | this.values == 1) && ...
                all(isfield(this, {'scale','offset'}))
            
            obj = WaveformChan(this);
        else % doesn't support marker channel
            obj = EventChan(this);
        end
        
        obj.Header = header;
        
        obj = K_setChanNumber(obj, srcdir, name_);
        
        rec = rec.addchan(obj);

    end
    
    list = filllist(list, name, srcdir, destdir, rec, i_mat);
    
    if exist('suffix','var')
        save(fullfile(destdir, [name_,suffix]), 'rec');
    else
        save(fullfile(destdir, name), 'rec'); 
    end
    
    clear  rec obj;
    fprintf('%s is done\n', name);    
    
    cd(curr.path);
    

    h = {'Name', 'srcdir', 'destdir', 'Start', 'MaxTime', 'Duration',...
        'SRate','SInterval','ChanTitles'};
end
end



function validateS(S)
chantitles = fieldnames(S);
for i = 1:length(chantitles)
    
    this = S.(chantitles{i});
    
    if all(isfield(this, {'title','interval','scale','offset','units','start', 'length', 'values'})) && ...
            ~all(this.values == 0 | this.values == 1)
        
        % waveform channel
    elseif all(isfield(this, {'title','interval','start', 'length', 'values'})) &&...
            all(this.values == 0 | this.values == 1)
        % event channel
    else
        error('K:K_folder_mat2record_save:validateS','The loaded .mat file contained data other than Spike2 export');
    end
    
end

end

function list = filllist(list, name, srcdir, destdir, rec, i)

    list{i,1} = name;
    list{i,2} = srcdir;
    list{i,3} = destdir;
    list{i,4} = rec.Start;
    list{i,5} = rec.MaxTime;
    list{i,6} = rec.MaxTime - rec.Start;
    list{i,7} = rec.SRate;
    list{i,8} = rec.SInterval;
    list{i,9} = rec.ChanTitles;

end


