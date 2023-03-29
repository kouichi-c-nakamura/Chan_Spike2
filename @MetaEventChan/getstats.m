function stats = getstats(obj)
% stats = getstats(obj)
%
% CV2 
% Holt GR, Softky WR, Koch C, Douglas RJ. 1996. Comparison of discharge
% variability in vitro and in vivo in cat visual cortex neurons. J
% Neurophysiol. 75:1806?814. PMID: 8734581
%
% See Also MetaEventChan

chantitle = obj.ChanTitle;
dur = obj.MaxTime - obj.Start;
n = obj.NSpikes;
frate = n/dur;

ISI = obj.ISI;

ISI_mean = mean(ISI);
ISI_STD = std(ISI, 1); % n-1
ISI_SEM = ISI_STD/sqrt(n);
ISI_CV = ISI_STD/ISI_mean;


isi = [NaN; ISI];
CV2 =  NaN(n, 1); %NaN is to avoid indices error in for loop
for i = 2:(n - 1)
    CV2(i,1) = 2 * abs(isi(i+1) - isi(i))/(isi(i+1) + isi(i)); %CV2 calculation
end

CV2 = CV2(~isnan(CV2));
CV2total = sum(CV2);
CV2mean = CV2total/(n-2);


%% output
stats.chantitle = chantitle;
stats.duration = dur;
stats.NSpikes = n;
stats.meanfiringrate = frate;

stats.ISI = ISI;
stats.ISI_mean = ISI_mean;
stats.ISI_STD = ISI_STD;
stats.ISI_SEM = ISI_SEM;
stats.ISI_CV = ISI_CV;

stats.ISI_CV2mean = CV2mean;
% stats.ISI_CV2total = CV2total;
stats.ISI_CV2 = CV2;

end