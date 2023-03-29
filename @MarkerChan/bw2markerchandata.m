function mk = bw2markerchandata(bwdata, start, srate, chantitle, varargin)
% MarkerChan.bw2markerchandata is a static method you can use to turn a
% column vector of zeros and ones representing alternating states into a
% MarkerChan object with maker code 1 for the onset of ones, and code 0 for
% the onset of zeros.
%
% This static method is useful we you want to realize something similar to
% "level" channel type of Spike2.
%
% SYNTAX
% mk = bw2markerchandata(bwdata,varargin)
% mk = bw2markerchandata(____,'Param',value)
%
% INPUT ARGUMENTS
% bwdata      column vector of 0s and 1s| column vector of logical
%             See also the description of mk below.
%
% start       scalar
%             Time at the start of file in seconds.
%
% srate       positive scalar
%             Sampling rate in Hz
%
% chantitle   row vector of characters
%
% OUTPUT ARGUMENTS
% mk          a MarkerChan object
%             Note that if the first element of bwdata is 1, then mk has a
%             marker code 1 at the first data point, but this may not
%             represent a real event of the state transition.
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 24-Oct-2018 11:23:37
%
% See also
% MarkerChan

p = inputParser;
p.addRequired('bwdata',@(x) iscolumn(x) && all(x == 0 | x == 1));
p.addRequired('start',@(x) isscalar(x));
p.addRequired('srate',@(x) isscalar(x) && x > 0);
p.addRequired('chantitle',@(x) isrow(x) && ischar(x));
p.parse(bwdata,start, srate, chantitle, varargin{:});


bwdata = logical(bwdata);

ON = find([diff(bwdata);0] == 1) +1;
OFF = find([diff(bwdata);0] == -1) +1;

tf = false(size(bwdata));

tf(ON) = true;
tf(OFF) = true;

codes = zeros(length(ON) + length(OFF),4);

% decide which one is ON

ONOFF = sort([ON;OFF]);

tfON = false(length(ON),1);

for i = 1:length(ON)
    
    tfON(ONOFF == ON(i)) = true;
    
end

codes(tfON,1) = 1;

if bwdata(1)
    tf(1) = true;
    codes = [1 0 0 0;codes];
end

mk = MarkerChan(tf,start,srate,codes,chantitle);


end

