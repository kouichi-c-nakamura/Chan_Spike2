function tBase = pvt_writesmr(rec,CEDS64MLpath,smrfilename,varargin)
% Write a 32 or 64 bit Spike2 data file (.smr) from Record object rec.
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
%
% smrfilename char row vector
%             File name (or file path) including .smr or .smrx suffix.
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
%             just assigns room in the file structure for the channels, the
%             file is created with no channels.
%             (Default) 400 channels (max) are set.
%             See CEDS64Create
%
% 'iType'     0 (default) | 1
%             The type of the file.
%             0 = 'small' 32-bit .smr ,
%             1 = 'large' 32-bit .smr.
%             2 = 64 bit .smrx
%
% OUTPUT ARGUMENT
% tBase       positive scalar double
%             The time base (clock tick) of the Spike2 file in seconds.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 21-Aug-2017 15:29:09
%
% See also
% CEDS64Create, CEDS64TimeBase, CEDS64SecsToTicks, Record.writesmrx

%TODO option to choose detailed channel type (fall, rise, level, textmark etc)
% 'type', {'','level','textmark','realwave'}
% '' for WaveformData



p = inputParser;
p.addRequired('rec');
p.addRequired('CEDS64MLpath',@(x) ischar(x) && isfolder(x));
p.addRequired('smrfilename', @(x) (ischar(x) && isrow(x)) || (isstring(x) && isscalar(x)));
p.addOptional('tBase',1.0000e-06,@(x) isscalar(x) && x >0);

p.addParameter('iChans',400,@(x) isscalar(x) && fix(x) == x && x > 0);
p.addParameter('iType',0,@(x) x == 0 || x == 1 || x == 2);
p.parse(rec,CEDS64MLpath,smrfilename,varargin{:});

tBase = p.Results.tBase;
iChans = p.Results.iChans;
iType = p.Results.iType;

if isstring(smrfilename)
    smrfilename = char(smrfilename);
end

%% Load CEDS64 library
if isempty(getenv('CEDS64ML')) || ~strcmp(getenv('CEDS64ML'),CEDS64MLpath)
    setenv('CEDS64ML',CEDS64MLpath); %NOTE: change as needed. The second argument must point to the folder 'CEDS64ML'
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);

CEDS64LoadLib( cedpath );


%%


fid = CEDS64Create(smrfilename,iChans,iType);
if fid < 0
    error('Cannot write Spike2 file. Maybe the file is open in Spike2?')
    %NOTE if smrfilename contains Japaneses characters, CEDS64Create fails.
end


%TODO
CEDS64TimeBase(fid,tBase);

for i = 1:length(rec.Chans)
   
    [i64Div,tBase] = get_i64Div(rec,tBase,i);
        
end

assert(length(rec.Chans) <= 400,'The number of channels exceeds 400.')

for i = 1:length(rec.Chans)

    %% EventChan
    if isa(rec.Chans{i},'EventChan')

        iOK = CEDS64SetEventChan(fid,i,rec.Chans{i}.SRate);
        if iOK == 0
            if ~isempty(rec.Chans{i}.TimeStamps)
                ticks = CEDS64SecsToTicks(fid,rec.Chans{i}.TimeStamps);

                fillret = CEDS64WriteEvents(fid,i,ticks);
            else
                warning('there is no event in the channel(%d): %s',i,rec.Chans{i}.ChanTitle)
            end

            iOK = CEDS64ChanTitle(fid,i,rec.Chans{i}.ChanTitle);

            if isfield(rec.Chans{i}.Header,'comment')
                iOK = CEDS64ChanComment(fid,i,rec.Chans{i}.Header.comment);
            end
        end

    %% WaveformChan
    elseif isa(rec.Chans{i},'WaveformChan')

        % i64Div = CEDS64ChanDiv(fid,3);
        % dRate  = CEDS64IdealRate(fid,3);

        dRate = rec.Chans{i}.SRate; % desired rate
        i64Div = round(rec.Chans{i}.SInterval/tBase);

        [chanscale,chanoffset] = WaveformChan.getScaleOffset(rec.Chans{i}.Data,'spike2');

        iOK    = CEDS64SetWaveChan(fid,i,i64Div,1,dRate);
        % iOK = CEDS64ChanDelete(fid,i)
        if iOK == 0
            CEDS64ChanScale(fid,i,chanscale);
            CEDS64ChanOffset(fid,i,chanoffset);

            % vMark must be single
            start = CEDS64SecsToTicks(fid, rec.Chans{i}.Start);
            
            vWave = int16((rec.Chans{i}.Data - chanoffset)*6553.6/chanscale);
            fillret = CEDS64WriteWave(fid,i,vWave,start); %TODO -9 error
            if fillret < 0
                CEDS64ErrorMessage(fillret); % Warning: Channel does not exist
                error('Error in CEDS64WriteWave')
            end

            iOK = CEDS64ChanTitle(fid,i,rec.Chans{i}.ChanTitle);

            iOK = CEDS64ChanUnits(fid,i,rec.Chans{i}.DataUnit);

            if isfield(rec.Chans{i}.Header,'comment')
                iOK = CEDS64ChanComment(fid,i,rec.Chans{i}.Header.comment);
            end
        end

    %% MarkerChan
    elseif isa(rec.Chans{i},'MarkerChan')

        if isa(rec.Chans{i},'WaveMarkChan')
            % [ iOk ] = CEDS64SetExtMarkChan( fhand, iChan, dRate, iType, iRows{,iCols{, i64Div}} )            
            iOK = CEDS64SetExtMarkChan(fid,i,rec.Chans{i}.SRate, 6, ...
                size(rec.Chans{i}.Traces,2), 1 , i64Div); %TODO iRows is the number of data points for trace

            if iOK == 0

                if rec.Chans{i}.NSpikes > 0
                    clear wmark
                    wmark(rec.Chans{i}.NSpikes, 1) = CEDWaveMark(); % create a vector of empty markers

                    ts = rec.Chans{i}.TimeStamps;
                    mc = rec.Chans{i}.MarkerCodes;                    
      
                    %NOTE SLOW but parfor cannot be used
                    % profile on
                    [chanscale,chanoffset] = WaveformChan.getScaleOffset(rec.Chans{i}.Traces,'spike2');
                    for m = 1:rec.Chans{i}.NSpikes
                        wmark(m).SetTime(CEDS64SecsToTicks(fid, ts(m))); %set time in ticks
                        wmark(m).SetCode(1, uint8(mc{m,1})); %set code 1
                        wmark(m).SetCode(2, uint8(mc{m,2})); %set code 2
                        wmark(m).SetCode(3, uint8(mc{m,3})); %set code 3
                        wmark(m).SetCode(4, uint8(mc{m,4})); %set code 4
                        
                        waveint16 = WaveformChan.doubleTOint16Spike2(...
                            rec.Chans{i}.Traces(m,:),chanscale,chanoffset)';
                        %NOTE must be a column or an array with up to 4 columns
                        
                        wmark(m).SetData(waveint16);
                        
                    end
                    clear m
                    % profile viewer


                    fillret = CEDS64WriteExtMarks(fid, i, wmark); %TODO
                    if fillret < 0
                        CEDS64ErrorMessage(fillret);
                    end
                end

                iOK = CEDS64ChanTitle(fid,i,rec.Chans{i}.ChanTitle);

                if isfield(rec.Chans{i}.Header,'comment')
                    iOK = CEDS64ChanComment(fid,i,rec.Chans{i}.Header.comment);
                end
                
                iOK = CEDS64ChanUnits(fid,i,rec.Chans{i}.DataUnit);
                
                iOK = CEDS64ChanScale(fid,i,chanscale);
                iOK = CEDS64ChanOffset(fid,i,chanoffset);
                
            end
                       
            
        else % MarkerChan
            
            if all(cellfun(@(x) isempty(x), rec.Chans{i}.TextMark))
                % MarkerChan
                
                iOK = CEDS64SetMarkerChan(fid,i,rec.Chans{i}.SRate);
                
                if iOK == 0
                    
                    if rec.Chans{i}.NSpikes > 0
                        clear vMark
                        vMark(rec.Chans{i}.NSpikes, 1) = CEDMarker(); % create a vector of empty markers
                        
                        ts = rec.Chans{i}.TimeStamps;
                        mc = rec.Chans{i}.MarkerCodes;
                        
                        %NOTE SLOW but parfor cannot be used
                        
                        for m = 1:rec.Chans{i}.NSpikes
                            vMark(m).SetTime(CEDS64SecsToTicks(fid, ts(m))); %set time in ticks
                            vMark(m).SetCode(1, uint8(mc{m,1})); %set code 1
                            vMark(m).SetCode(2, uint8(mc{m,2})); %set code 2
                            vMark(m).SetCode(3, uint8(mc{m,3})); %set code 3
                            vMark(m).SetCode(4, uint8(mc{m,4})); %set code 4
                        end
                        clear m
                        
                        
                        fillret = CEDS64WriteMarkers(fid, i, vMark);
                        if fillret < 0
                            CEDS64ErrorMessage(fillret);
                        end
                    end
                    
                    iOK = CEDS64ChanTitle(fid,i,rec.Chans{i}.ChanTitle);
                    
                    if isfield(rec.Chans{i}.Header,'comment')
                        iOK = CEDS64ChanComment(fid,i,rec.Chans{i}.Header.comment);
                    end
                end
                
                
            else % TextMarkChan
                                
                iOK = CEDS64SetTextMarkChan(fid,i,rec.Chans{i}.SRate,1024); % up to 128 characters
  
                 if iOK == 0
                    
                    if rec.Chans{i}.NSpikes > 0
                        clear tMark
                        tMark(rec.Chans{i}.NSpikes, 1) = CEDTextMark(); % create a vector of empty markers
                        
                        ts = rec.Chans{i}.TimeStamps;
                        mc = rec.Chans{i}.MarkerCodes;
                        tx = rec.Chans{i}.TextMark;
                        
                        %NOTE SLOW but parfor cannot be used
                        
                        for m = 1:rec.Chans{i}.NSpikes
                            tMark(m).SetTime(CEDS64SecsToTicks(fid, ts(m))); %set time in ticks
                            tMark(m).SetCode(1, uint8(mc{m,1})); %set code 1
                            tMark(m).SetCode(2, uint8(mc{m,2})); %set code 2
                            tMark(m).SetCode(3, uint8(mc{m,3})); %set code 3
                            tMark(m).SetCode(4, uint8(mc{m,4})); %set code 4
                            tMark(m).SetData(tx{m});
                        end
                        clear m
                        
                        
                        fillret = CEDS64WriteExtMarks(fid, i, tMark);
                        if fillret < 0
                            CEDS64ErrorMessage(fillret);
                        end
                    end
                    
                    iOK = CEDS64ChanTitle(fid,i,rec.Chans{i}.ChanTitle);
                    
                    if isfield(rec.Chans{i}.Header,'comment')
                        iOK = CEDS64ChanComment(fid,i,rec.Chans{i}.Header.comment);
                    end
                 end
            end
        end
    end

end

iOK = CEDS64Close( fid );
% CEDS64CloseAll

disp(smrfilename)

unloadlibrary ceds64int

end


function [i64Div,tBase] = get_i64Div(rec,tBase,i)

i64Div_ = rec.Chans{i}.SInterval/tBase;

if abs(fix(i64Div_) - i64Div_) < eps('single') %NOTE somehow, even when dInterval is multiple of tBase, i64Div_ is not strictly an integer
    i64Div = round(i64Div_);
else
    error(['The sampling interval of Record object %f microsec was not an integer', ...
        ' multiple of the clock ticks %f microsec (file time base (the length of each tick) [see CEDS64TimeBase.m]). '],...
        rec.Chans{i}.SInterval*10^6,...
        tBase*10^6,...
        tBase_new*10^6)
end

end