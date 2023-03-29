function recout = vertcat(rec1,varargin)
%VERTCAT  Overloaded vertical concatenation for Record object 
%
%   rec = vertcat(rec1, rec2, ...) performs
%
%         rec = [rec1 ; rec2 ; ...]
% 
%   This operation appends Record objects.  The time vectors must not
%   overlap.  The last time in rec1 must be earlier than the first time in
%   rec2.  All the Record objects to be combined must have the same
%   time series members.      


if nargin==1
    recout = rec1;
    return
else
    rec{1} = rec1;
    for i=2:length(varargin)+1
        if isa(varargin{i-1},'Record')
            rec{i} = varargin{i-1}; %#ok<AGROW>
        else
            error('K:Record:vertcat:badtype',...
                'All of them have to be Record objects')
        end
    end
end

recout = rec{1};
for i=1:length(varargin)
    recout = utdualvertcat(recout,rec{i+1});
end


function recout = utdualvertcat(rec1,rec2)
%UTDUALHORZCAT vertical concatenation on two Record object

% Check that the members match

ChanTitles1 = rec1.ChanTitles;
ChanTitles2 = rec1.ChanTitles;

if length(ChanTitles1) ~= length(ChanTitles2)
    error('K:Record:vertcat:Chans:ChanTitles:mismatch',...
        'Chans of 2 Record objects must share the same ChanTitles.');
end

mismatchingChanTitles = union(setdiff(ChanTitles1,ChanTitles2),setdiff(ChanTitles2,ChanTitles1));
if ~isempty(mismatchingChanTitles)
    error('K:Record:vertcat:Chans:ChanTitles:mismatch',...
        'Chans of 2 Record objects must share the same ChanTitles.');
end


% check if they share SRate
if rec1.SRate ~= rec2.SRate
    error('K:Record:vertcat:SRate:mismatch',...
        'SRate of 2 Record objects must be the same.');
end


% get matching indices for rec1.Chans and rec2.Chans

[~, ind1] = sort(ChanTitles1);
[~, rev] = sort(ind1);

[~, ind2] = sort(ChanTitles2);

chanset1 = rec1.Chans;
chanset2 = rec2.Chans(ind2(rev));
newchan = cell(length(ChanTitles1), 1);


for i = 1:length(ChanTitles1)
    newchan{i, 1} = [chanset1{i}; chanset2{i}];
end

% Construct output Record
recout = Record(newchan, 'Name', rec1.RecordTitle);



