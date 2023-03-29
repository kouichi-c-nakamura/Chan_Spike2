function states = Kouichi_UPDOWNwavelet(EEG, slow_lowpass, phase_threshold, time_threshold)
%
%     1. Script of slow oscillation analysis
%     --------------------------------------
%     CALCULUS: Script extracting UP and DOWN states based on the phase of a
%     wavelet transform
%
%     INPUT:
%     EEG                    vector of waveform data sampled at 1000 Hz
%     slow_lowpass           [Hz] - frequency to analyse (default 2),
%     phase_threshold        between -1 and 1 (dafault is 0);
%     time_threshold         [msec] for states
%
%
%     OUTPUT: selected prestates, where columns 1:3=UP and 4:6=DOWN
%     1 UP start (msec)
%     2 UP end
%     3 UP duration
%     4 DOWN start
%     5 DOWN end
%     6 DOWN duration
%     7 skip (after this to the next cycle)
%
%
%     EXAMPLE: [prestates]=slow1_states_240910(EEG,2.5,0,300)
%
%     based on Michael Lagler's code
%     Massi L, Lagler M, Hartwich K, Borhegyi Z, Somogyi P, Klausberger T.
%     2012. Temporal dynamics of parvalbumin-expressing axo-axonic and
%     basket cells in the rat medial prefrontal cortex in vivo. J Neurosci.
%     32:16496–16502.
%
%      03.02.11 by ML


EEG = - EEG;% KOUICHI Up side Down for my EEG


%%% 1.downsample data
% % [b,a]=butter(6,0.25,'low');EEG=filtfilt(b,a,EEG);
downfactor = 1;
% EEG = downsample(EEG, downfactor);

%%% 2.wavelet parameters
wname = 'db3'; % this choice of the wavelet is the key
SC = 50:50:1200;
SR = 1000/downfactor;
f = scal2frq(SC,wname,1/SR);

%%% 3.wavelet transform
wave = cwt(EEG,SC,wname);
disp(['cwt is done.', datestr(now, 'HH:MM:SS')]);% KOUICHI

PH = angle(wave)./pi.*180+180;

%%% 4.wave processing

targetPH = PH(find(f<slow_lowpass),:);%vectorised by RDS - tested for identical results

disp(['targetPH is done.', datestr(now, 'HH:MM:SS')]);% KOUICHI


mPH = atan2(mean(sin(targetPH.*pi./180)),mean(cos(targetPH.*pi./180))).*180./pi; %%% angular mean
L = cosd(mPH);

%%% 5. phase thresholding
EEGLslow = [(1:downfactor:length(EEG)*downfactor)',EEG,L'];

ind = L>=phase_threshold; %vectorised by RDS - tested for identical results
UPslow = EEGLslow(find(ind),1:2);
DOWNslow = EEGLslow(find(~ind),1:2);
disp(['UPslow and DOWNslow are done.', datestr(now, 'HH:MM:SS')]);% KOUICHI


%%% 6. extracting state times

%Vectorised by RDS - tested for identical results
UP = [UPslow(:,1),[diff(UPslow(:,1));UPslow(end,2)]];
DOWN = [DOWNslow(:,1),[diff(DOWNslow(:,1));DOWNslow(end,2)]];
%Issue with the fact that the last element here is not a diff but a raw
%value from the EEG? i.e. DOWN(end,2)==EEG(end)

disp(['UP and DOWN are done.', datestr(now, 'HH:MM:SS')]);% KOUICHI

UPgap = UP(UP(:,2)>downfactor, 1); %KOUICHI
DOWNgap = DOWN(DOWN(:,2)>downfactor, 1); %KOUICHI


UPgap1 = [];
if length(UPgap) > length(DOWNgap);
    UPgap1 = [UPgap1;UPgap(1:(length(UPgap)-1),1)];
elseif length(UPgap) <= length(DOWNgap);
    UPgap1 = UPgap;
end
UPgap = UPgap1;
DOWNgap1 = [];
if length(DOWNgap) > length(UPgap);
    DOWNgap1 = [DOWNgap1;DOWNgap(1:(length(DOWNgap)-1),1)];
elseif length(DOWNgap) <= length(UPgap);
    DOWNgap1 = DOWNgap;
end
DOWNgap = DOWNgap1;
states = DOWNgap;
states(:,2) = UPgap;
statesdown = UPgap;
statesdown(:,2) = DOWNgap;

%%% 7.Rejection 1 (UP or DOWN states below time threshold)
dur=[];
if states(:,2)<=states(:,1);
    dur=[dur,states(1:(length(states)-1),1),states(2:length(states),2)];
elseif states(:,2)>states(:,1);
    dur=states;
end
dur(:,3)=dur(:,2)-dur(:,1);
durdown=[];
if statesdown(:,2)<=statesdown(:,1);
    durdown=[durdown,statesdown(1:(length(statesdown)-1),1),statesdown(2:length(statesdown),2)];
elseif statesdown(:,2)>statesdown(:,1);
    durdown=statesdown;
end
durdown(:,3)=durdown(:,2)-durdown(:,1);
if length(dur)>length(durdown);
    dur=dur(1:(length(dur)-1),1:end);
elseif length(dur)<length(durdown);
    durdown=durdown(1:(length(durdown)-1),1:end);
end
states_dur=[dur,durdown];
states_dur=states_dur.*downfactor;

states_sel = states_dur(states_dur(:,3)>time_threshold & states_dur(:,6)>time_threshold, 1:end);


%%% 8.Rejection 2 (>3 consectutive slow oscillation cycles)
if states_sel(1,1)<states_sel(1,4);
    for i=1:length(states_sel)-1;
        states_sel(i,7)=states_sel(i+1,1)-states_sel(i,5);
    end
end
if states_sel(1,1)>states_sel(1,4);
    for i=1:length(states_sel)-1;
        states_sel(i,7)=states_sel(i+1,4)-states_sel(i,2);
    end
end

states_cons=[];
for i=3:length(states_sel)-2;
    if states_sel(i-1,7)==0 && states_sel(i,7)==0 && states_sel(i+1,7)==0 ...
            || states_sel(i,7)==0 && states_sel(i+1,7)==0 &&...
            states_sel(i+2,7)==0 || states_sel(i-2,7)==0 &&...
            states_sel(i-1,7)==0 && states_sel(i,7)==0;
        states_cons=[states_cons;states_sel(i,1:end)];
    end
end
states=states_sel;

end
