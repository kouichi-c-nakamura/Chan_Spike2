function mk = uint2markerchandata(uintdata, start, srate, chantitle, varargin)
% MarkerChan.uint2markerchandata is a static method you can use to turn a
% column vector of non-negative integers (0 to 255) representing multiple
% states into a MarkerChan object.
%
% INPUT ARGUMENTS
% uintdata    column vector integers ranging 0 to 255
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
% 26-Nov-2018 13:12:55
%
% See also
% MarkerChan
% MarkerChan.bw2markerchandata


p = inputParser;
p.addRequired('uintdata',@(x) iscolumn(x) && all(fix(x) == x) && all(x >= 0) ....
    && all(x <=255)); % intmax of uint8 is 255
p.addRequired('start',@(x) isscalar(x));
p.addRequired('srate',@(x) isscalar(x) && x > 0);
p.addRequired('chantitle',@(x) isrow(x) && ischar(x));
p.parse(uintdata,start, srate, chantitle, varargin{:});


n = nnz(uintdata);
codes = uint8(zeros(n,4));


uq = unique(uintdata);

for i = 1:length(uq)
       
    codes(uq(i) == uintdata,1) = uq(i);
    
end


data = uintdata ~= 0;

mk = MarkerChan(data, start, srate, codes, chantitle);


end