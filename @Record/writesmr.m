function tBase = writesmr(rec,CEDS64MLpath,smrfilename,tBase,args)
% Write a 32 bit Spike2 data file (.smr) from Record object rec.
% 
% tBase = writesmr(rec,CEDS64MLpath,smrfilename)
% tBase = writesmr(rec,CEDS64MLpath,smrfilename,tBase)
% tBase = writesmr(rec,_____,'Param',value)
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
% smrfilename char row vector
%             File name (or file path) including .smr suffix.
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
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'iChans'    The maximum number of channels the file can have, note this
%             just assigns room in the file structure for the channels, the file is
%             created with no channels.
%             (Default) 400 channels (max) are set.
%             See CEDS64Create
%
% 'iType'     0 (default) | 1 
%             The type of the file. 
%             0 = 'small' 32-bit .smr , 
%             1 = 'large' 32-bit .smr.
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
% CEDS64Create, CEDS64TimeBase, CEDS64SecsToTicks, Record.writesmrx, pvt_writesmr

%TODO option to choose detailed channel type (fall, rise, level, textmark etc)
% 'type', {'','level','textmark','realwave'}
% '' for WaveformData

arguments
    rec
    CEDS64MLpath (1,:) char {vf_CEDS64MLpath(CEDS64MLpath)}
    smrfilename (1,:) char {vf_smrfilename(smrfilename)}
    tBase (1,1) double {mustBePositive} = 1.0000e-06
    
    args.iChans (1,1) double {mustBePositive, mustBeInteger} = 400
    args.iType (1,1) double {mustBeMember(args.iType,[0 1])} = 0
    args.IgnoreStart (1,1) logical = false

end

if ~ispc
    error('This method is only available in Windows with 64 bit MATLAB SON Interface installed. http://ced.co.uk/upgrades/spike2matson')
end


iChans = args.iChans;
iType = args.iType;
ignoreStart = args.IgnoreStart;

tBase = pvt_writesmr(rec,CEDS64MLpath,smrfilename,tBase,'iChans',iChans,...
    'iType',iType,'IgnoreStart',ignoreStart);

end

function vf_CEDS64MLpath(x)

assert(isfolder(x))

end

function vf_smrfilename(x)

assert(ismatched(x,'\.smr$'))

end
