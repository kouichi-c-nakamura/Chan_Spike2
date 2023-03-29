function tBase = writesmrx(rec,CEDS64MLpath,smrxfilename,tBase,args)
% Write a 64 bit Spike2 data file (.smrx) from Record object rec.
% 
% tBase = writesmrx(rec,CEDS64MLpath,smrxfilename)
% tBase = writesmrx(rec,CEDS64MLpath,smrxfilename,tBase)
% tBase = writesmrx(rec,_____,'Param',value)
%
% REQUIREMENTS
% You need Spike2 MATLAB SON Interface installed. You can get it from the
% line below for free.
% http://ced.co.uk/upgrades/spike2matson
%
%
% INPUT ARGUMENTS
% rec         A Record objecat
%
% CEDS64MLpath
%             char
%             Folder path for 'CEDS64ML', the folder contains MATLAB
%             functions and .dll libraries for Spike2 MATLAB SON Interface.
%
%             Examples:
%               CEDS64MLpath = fullfile(findbasedir,'matlab_toolbox','matson','CEDS64ML')
%               CEDS64MLpath = 'C:\Users\xxxxxxx\Documents\MATLAB\SON\CEDS64ML'
%               CEDS64MLpath = 'X:\00 SCRIPTS\00 Toolboxes\CEDmatlab\CEDS64ML'
%
% smrxfilename char row vector
%             File name (or file path) including .smrx suffix.
%
% tBase       scalar real number
%             (Optional) The time base (tick interval in seconds) for the
%             new Spike2 .smrx file See CEDS64TimeBase for more details
%
%             (Default)
%             tBase = 1.0000e-06 (1 microseconds)
%
%             tBase being 1e-6 to 5e-6 (1 to 5 microseconds) may be a good
%             range for this.
%
%             The sampling interval of the new file must be integer
%             multiple of the tBase. Instead of compromising sampling rate,
%             by dafault, tBase will be adapted so that the samping
%             interval is 10x, 100x, ... etc of the clock tick with a
%             warning.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'iChans'    The maximum number of channels the file can have, note this
%             just assigns room in the file structure for the channels, the file is
%             created with no channels.
%             (Default) 400 channels (max) are set.
%             See CEDS64Create
%
% 'IgnoreStart'
%             false (default) | true
%             If false, Start property of rec is used in Spike 2 file. If
%             Start is not 0 (eg. 120), you'll see blank data at the
%             beginning of the Spike2 file (eg. for 120 sec). If true,
%             Start propery is overwritten as 0 and data appear from the
%             beginning of the Spike2 file.
%
% OUTPUT ARGUMENT
% tBase       positive scalar double
%             The time base (clock tick) of the Spike2 file in seconds.
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 21-Aug-2017 15:29:09
%
% See also
% CEDS64Create, CEDS64TimeBase, CEDS64SecsToTicks, Record.writesmr, pvt_writesmr

%TODO option to choose detailed channel type 
% for EventChan  {'event', 'level+', 'level-'}
% for MarkerChan {'marker', 'textmark'}
% t = table(chan_iind, chan_type) as optinal input argument?

% 'type', {'','level','textmark','realwave',''}
% '' for WaveformData

arguments
    rec
    CEDS64MLpath (1,:) char {vf_CEDS64MLpath(CEDS64MLpath)}
    smrxfilename (1,:) char {vf_smrxfilename(smrxfilename)}
    tBase (1,1) double {mustBePositive} = 1.0000e-06
    
    args.iChans (1,1) double {mustBePositive, mustBeInteger} = 400
    args.IgnoreStart (1,1) logical = false
    
end


if ~ispc
    error('This method is only available in Windows with 64 bit MATLAB SON Interface installed. http://ced.co.uk/upgrades/spike2matson')
end


iChans = args.iChans;
iType = 2; % 64 bit
ignoreStart = args.IgnoreStart;

tBase = pvt_writesmr(rec,CEDS64MLpath,smrxfilename,tBase,'iChans',iChans,...
    'iType',iType,'IgnoreStart',ignoreStart);

end

function vf_CEDS64MLpath(x)

assert(isfolder(x))

end

function vf_smrxfilename(x)

assert(ismatched(x,'\.smrx$'))

end
