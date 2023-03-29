function rec = readsmr(CEDS64MLpath,smrfilename,varargin)
% RecordA.readsmr is a static method that offers you an instant way of
% loading Spike2 data into MATLAB.
%
% NOTE
% Because the respresentation of event channels with EventChan is based on
% a vector of ones and zeros, whereas Spike2 uses timestamps internally,
% the event channels must be given a sampling rate FsEvent for binning. For
% this conversion, data in the event channels is always altered from the
% original in Spike 2 file.
%
%
% SYNTAX
% rec = RecordA.readsmr(CEDS64MLpath,smrfilename)
% rec = RecordA.readsmr(CEDS64MLpath,smrfilename,FsEvent)
%
% longer description may come here
%
% INPUT ARGUMENTS
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
%             File name (or file path) including .smr or .smrx suffix.
%
% FsEvent     postive scalar number
%             Sampling rate for EventChan
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% 'C'         'on' (default) | 'off'
%             (Optional) Description about 'C' comes here.
%
%
% OUTPUT ARGUMENTS
% rec         an RecordA object 
%             
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 16-Sep-2019 17:19:25
%
% See also
% RecordA.writesmr, RecordA.writesmrx, Record.writesmr, Record.writesmrx, 


p = inputParser;
p.addRequired('CEDS64MLpath',@(x) ischar(x) && isfolder(x));
p.addRequired('smrfilename',@(x) ischar(x) && isfile(x));
p.addOptional('FsEvent',30000,@(x) isreal(x) && isscalar(x) && x > 0);
p.parse(CEDS64MLpath,smrfilename,varargin{:});

FsEvent = p.Results.FsEvent;


%% Load CEDS64 library
if isempty(getenv('CEDS64ML')) || ~strcmp(getenv('CEDS64ML'),CEDS64MLpath)
    setenv('CEDS64ML',CEDS64MLpath); %NOTE: change as needed. The second argument must point to the folder 'CEDS64ML'
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);

CEDS64LoadLib( cedpath );


%%

iMode = 1; % read only

fid = CEDS64Open (smrfilename,iMode);
if fid < 0
    error('Maybe the file is open in Spike2?')
    %NOTE if smrfilename contains Japaneses characters, CEDS64Create fails.
end

tBase = CEDS64TimeBase(fid);

Tchanlist = CEDS64ChanList(fid);


C = cell(height(Tchanlist),1);

for ch = 1:height(Tchanlist)
    
   switch Tchanlist.ChanType{ch}
       case 'Waveform'
           %TODO scale and offset
           
           maxTimeTicks = CEDS64ChanMaxTime(fid, ch)+1; %NOTE http://www.ced.co.uk/phpBB3/viewtopic.php?f=5&t=2062&e=1&view=unread#unread
           
           i64Div = CEDS64ChanDiv(fid, ch);
           
           iN = floor(maxTimeTicks/i64Div) ;
           
           [fRead, vi16Wave, i64Time] = CEDS64ReadWaveS( fid, ch, iN, 0, maxTimeTicks );
           
           [~, chanscale] = CEDS64ChanScale(fid,ch);
           
           [~, chanoffset] = CEDS64ChanOffset(fid,ch);
           
           [~,chantitle] = CEDS64ChanTitle(fid,ch);
           
           [~,chancomment] = CEDS64ChanComment(fid,ch);  %TODO
           
           
           Fs = 1/(i64Div*tBase);
           
           
           doubledata = WaveformChan.int16TOdoubleSpike2(vi16Wave,chanscale, chanoffset);
           [scale,offset] = WaveformChan.getScaleOffset(doubledata);
           clear doubledata
           
           w = WaveformChan(vi16Wave, double(i64Time)*tBase, Fs, scale, offset, chantitle);
           w.Header.chanscale = chanscale;
           w.Header.chanoffset = chanoffset;
           
           % w.ChanNumber = ch; %TODO
           
           w.Header.comment = channcomment;
           
           C{ch} = w;
           
           clear i64Div fRead vi16Wave i64Time Fs w
           
       case {'Event (falling)','Event (rising)','Event (both)'}
           
           maxTimeTicks = CEDS64ChanMaxTime(fid, ch)+1; %NOTE http://www.ced.co.uk/phpBB3/viewtopic.php?f=5&t=2062&e=1&view=unread#unread
           
           [iRead, vi64T] = CEDS64ReadEvents( fid, ch, maxTimeTicks, 0, maxTimeTicks ); %TODO vector<T> too long
           
           [~,chantitle] = CEDS64ChanTitle(fid,ch);
           
           [~,chancomment] = CEDS64ChanComment(fid,ch);  %TODO
           
           yy = timestamps2binned(double(vi64T)*tBase, 0, maxTimeTicks*tBase, FsEvent);           
           
           e = EventChan(yy, 0, FsEvent, chantitle);
           
           e.Header.comment = channcomment;
           
           % w.ChanNumber = ch; %TODO
           
           C{ch} = e;

           clear iRead vi64T chantitle chancomment yy e
           
       case {'Marker','TextMark'}
           
           
           maxTimeTicks = CEDS64ChanMaxTime(fid, ch)+1; %NOTE http://www.ced.co.uk/phpBB3/viewtopic.php?f=5&t=2062&e=1&view=unread#unread
           
           [iRead, vMObj] = CEDS64ReadMarkers( fid, ch, maxTimeTicks, 0, maxTimeTicks ); %TODO
           
           [~,chantitle] = CEDS64ChanTitle(fid,ch);
           
           [~,chancomment] = CEDS64ChanComment(fid,ch);  %TODO
           
           yy = timestamps2binned(double(vertcat(vMObj.m_Time))*tBase, 0, maxTimeTicks*tBase, FsEvent);
                      
           codes = [vertcat(vMObj.m_Code1),vertcat(vMObj.m_Code2),...
               vertcat(vMObj.m_Code3),vertcat(vMObj.m_Code4)];                     
           
           m = MarkerChan(yy, 0, FsEvent, codes,  chantitle);
           
           % w.ChanNumber = ch; %TODO
           
           C{ch} = m;
           
           clear m yy codes vMObj chantitle chancomment
           
       case 'Wavemark'
           
           %TODO not implemented

           keyboard
           
   end
           
    
    
    
    
    
    
    
    
end

rec = RecordA(C,'Name',smrfilename);


iOK = CEDS64Close(fid);
if iOK ~= 0 
   error('CEDS64Close failed') 
end








end