function appendsmr(rec,CEDS64MLpath,smrfilename,args)
% appendsmr allows you to append the channels in a Record object to an
% existing Spike2 file (.smr or .smrx) as long as the sampling interval of
% the Record object is integer multiple of the time base of the Spike2
% file.
%
% tBase = appendsmr(rec,CEDS64MLpath,smrfilename)
% tBase = appendsmr(rec,_____,'Param',value)
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
%             The name (or file path) of existing Spike2 file including
%             .smr (32 bit file) or .smrx (64 bit file) suffix.
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
%
% 'destChans'
%             a vector of positive integers
%             Destination channel numbers. They must be empty. 
%
% 'StartAs0'  true | false (default)
%             If true, the Start property of the Record object is
%             overwritten as 0.
%
% OUTPUT ARGUMENT
% tBase       positive scalar double
%             The time base (clock tick) of the Spike2 file in seconds.
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 09-Sep-2019 17:33:55
%
% See also
% writesmrx, writesmr, pvt_writesmr

%TODO refactor with Record.appendsmr

arguments
   rec
   CEDS64MLpath (1,:) char {vf_CEDS64MLpath(CEDS64MLpath)}
   smrfilename  (1,:) char {vf_smrfilename(smrfilename)}
   args.destChans {vf_destChans(args.destChans)} = []
   args.StartAs0 (1,1) logical = false
end  
    

destChans = args.destChans;
startAs0 =  args.StartAs0;

if startAs0
    rec.Start = 0;
end


%% Load CEDS64 library
if isempty(getenv('CEDS64ML')) || ~strcmp(getenv('CEDS64ML'),CEDS64MLpath)
    setenv('CEDS64ML',CEDS64MLpath); %NOTE: change as needed. The second argument must point to the folder 'CEDS64ML'
end
cedpath = getenv('CEDS64ML');
addpath(cedpath);

CEDS64LoadLib( cedpath );

%%


fid = CEDS64Open(char(smrfilename),0); % read/write mode for appending
if fid < 0
    error('Maybe the file is open in Spike2?')
    %NOTE if smrfilename contains Japaneses characters, CEDS64Create fails.
end



%% check timebase compatibility

tBase = CEDS64TimeBase(fid); % in seconds


for i = 1:length(rec.Chans)

    dRate = rec.Chans{i}.SRate; % desired rate
    dInterval_microsec = 1/dRate * 10^6;
    i64Div_ = rec.Chans{i}.SInterval/tBase;

    if abs(fix(i64Div_) - i64Div_) < eps('single') %NOTE somehow, even when dInterval is multiple of tBase, i64Div_ is not strictly an integer
        i64Div = round(i64Div_);
    else
        error('The time base of the file %s is %f %ssec, but the desired sampling interval %f %ssec is not an integer multiple of the time base in %d th channel "%s".',...
            smrfilename, tBase*10^6, char_greekmu, dInterval_microsec, char_greekmu, i, rec.ChanTitles{i} )
    end

end


%%

Tchanlist = CEDS64ChanList(fid);

emptyChans = setdiff(1:400,Tchanlist.ChanNumber);

if isempty(destChans)
    
    targetChans = emptyChans (1:length(rec.Chans));

else
    
    assert(all(ismember(destChans,emptyChans)),...
        'destChans must be empty channels.')
    
    if iscolumn(destChans)
        destChans = destChans';
    end
    
    targetChans = destChans;
    
end


%NOTE below is almost identical to pvt_writesmr

assert(length(rec.Chans) <= 400,'The number of channels exceeds 400.')

for i = 1:length(targetChans)
    
    ch = targetChans(i);

    %% EventChan
    if isa(rec.Chans{i},'EventChan')

        iOK = CEDS64SetEventChan(fid,ch,rec.Chans{i}.SRate);
        if iOK == 0
            if ~isempty(rec.Chans{i}.TimeStamps)
                ticks = CEDS64SecsToTicks(fid,rec.Chans{i}.TimeStamps);

                fillret = CEDS64WriteEvents(fid,ch,ticks);
            else
                warning('there is no event in the channel(%d): %s',i,rec.Chans{i}.ChanTitle)
            end

            iOK = CEDS64ChanTitle(fid,ch,rec.Chans{i}.ChanTitle);

            if isfield(rec.Chans{i}.Header,'comment')
                iOK = CEDS64ChanComment(fid,ch,rec.Chans{i}.Header.comment);
            end
        end

    %% WaveformChan
    elseif isa(rec.Chans{i},'WaveformChan')

        % i64Div = CEDS64ChanDiv(fid,3);
        % dRate  = CEDS64IdealRate(fid,3);

        % dRate = rec.Chans{i}.SRate; % desired rate
        % i64Div = round(rec.Chans{i}.SInterval/tBase);%TODO error

        [chanscale,chanoffset] = WaveformChan.getScaleOffset(rec.Chans{i}.Data,'spike2');

        iOK    = CEDS64SetWaveChan(fid,ch,i64Div,1,dRate);
        % iOK = CEDS64ChanDelete(fid,ch)
        if iOK == 0
            CEDS64ChanScale(fid,ch,chanscale);
            CEDS64ChanOffset(fid,ch,chanoffset);

            % vMark must be single
            start = CEDS64SecsToTicks(fid, rec.Chans{i}.Start);

            vWave = int16((rec.Chans{i}.Data - chanoffset)*6553.6/chanscale);
            fillret = CEDS64WriteWave(fid,ch,vWave,start); %TODO -9 error
            if fillret < 0
                CEDS64ErrorMessage(fillret); % Warning: Channel does not exist
                error('Error in CEDS64WriteWave')
            end

            iOK = CEDS64ChanTitle(fid,ch,rec.Chans{i}.ChanTitle);

            iOK = CEDS64ChanUnits(fid,ch,rec.Chans{i}.DataUnit);

            if isfield(rec.Chans{i}.Header,'comment')
                iOK = CEDS64ChanComment(fid,ch,rec.Chans{i}.Header.comment);
            end
        end

    %% MarkerChan
    elseif isa(rec.Chans{i},'MarkerChan')

        if isa(rec.Chans{i},'WaveMarkChan')
            % [ iOk ] = CEDS64SetExtMarkChan( fhand, iChan, dRate, iType, iRows{,iCols{, i64Div}} )            
            iOK = CEDS64SetExtMarkChan(fid,ch,rec.Chans{i}.SRate, 6, ...
                size(rec.Chans{i}.Traces,2), 1 , i64Div); %TODO iRows is the number of data points for trace

            if iOK == 0

                if rec.Chans{i}.NSpikes > 0
                    clear wmark
                    wmark(rec.Chans{i}.NSpikes, 1) = CEDWaveMark(); % create a vector of empty markers

                    ts = rec.Chans{i}.TimeStamps;
                    mc = rec.Chans{i}.MarkerCodes;                    
      
                    %NOTE SLOW but parfor cannot be used
                    % profile on
                    for m = 1:rec.Chans{i}.NSpikes
                        wmark(m).SetTime(CEDS64SecsToTicks(fid, ts(m))); %set time in ticks
                        wmark(m).SetCode(1, uint8(mc{m,1})); %set code 1
                        
                        [chanscale,chanoffset] = WaveformChan.getScaleOffset(rec.Chans{i}.Traces); %TODO
                        waveint16 = WaveformChan.doubleTOint16Spike2(rec.Chans{i}.Traces(m,:),chanscale,chanoffset)';
                        
                        wmark(m).SetData(waveint16); %TODO where can I specify chanscale and chanoffset for output???
                        
                    end
                    clear m
                    % profile viewer


                    fillret = CEDS64WriteExtMarks(fid, ch, wmark); %TODO
                    if fillret < 0
                        CEDS64ErrorMessage(fillret);
                    end
                end

                iOK = CEDS64ChanTitle(fid,ch,rec.Chans{i}.ChanTitle);

                if isfield(rec.Chans{i}.Header,'comment')
                    iOK = CEDS64ChanComment(fid,ch,rec.Chans{i}.Header.comment);
                end
                
                iOK = CEDS64ChanUnits(fid,ch,rec.Chans{i}.DataUnit);
                
                iOK = CEDS64ChanScale(fid,ch,chanscale);
                iOK = CEDS64ChanOffset(fid,ch,chanoffset);
                
            end
                       
            
        else % MarkerChan

            iOK = CEDS64SetMarkerChan(fid,ch,rec.Chans{i}.SRate);

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
                    end
                    clear m
                    

                    fillret = CEDS64WriteMarkers(fid, ch, vMark);
                    if fillret < 0
                        CEDS64ErrorMessage(fillret);
                    end
                end

                iOK = CEDS64ChanTitle(fid,ch,rec.Chans{i}.ChanTitle);

                if isfield(rec.Chans{i}.Header,'comment')
                    iOK = CEDS64ChanComment(fid,ch,rec.Chans{i}.Header.comment);
                end
            end
        
        
        end
        
        
        



    end


end

iOK = CEDS64Close( fid );
% CEDS64CloseAll

fprintf('modified %s\n',smrfilename);

unloadlibrary ceds64int




end

function vf_CEDS64MLpath(x)

assert(isfolder(x))

end

function vf_smrfilename(x)

assert(endsWith(x,{'.smr','.smrx'}))

end

function vf_destChans(x)

assert(isempty(x) || isvector(x) && all(fix(x) == x) && all(x > 0) && all(x <= 400))

end