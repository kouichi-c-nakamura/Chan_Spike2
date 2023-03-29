%% WaveMarkChan_demo.mlx
% 
% 
% 
% 
% 
% 
% 

S = load(fullfile(fileparts(which('WaveMarkChan')),'kjx021I01_i02_spliced_30_wm.mat'));

traces = S.nw_3.values;

codes = S.nw_3.codes;

yy = timestamps2binned(S.nw_3.times,0,20,17000,'normal');

wm = WaveMarkChan(yy, 0, 17000, codes, traces, S.nw_3.scale, S.nw_3.offset, S.nw_3.trigger, 'nw_3')
testCase.verifyEqual(wm.NSpikes,1618)

wm.plot



wm1 =  wm.extractTime(0.75, 0.85)

wm1.plot



wm1.MarkerFilter{'value1',1} = false;

wm1.NSpikes 

size(wm1.Traces)

wm1.plot


%% extractTIme method

wm1.MarkerFilter = [];

wm1.plot