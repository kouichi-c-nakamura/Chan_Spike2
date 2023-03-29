function rec = smr2rec( smrname, sRateNew, varargin )
% smr2rec converts specified channels of Spike 2 .smr files into a Record
% object.
%
% rec = smr2rec( smrname, sRateNew )
% rec = smr2rec( smrname, sRateNew, channumbers )
%
% INPUT ARGUMENTS
% smrname     char
%             Name of .smr file including file extention.
%
% sRateNew    positive scalar
%             New sampling rate
%
% channumbers List of chan numbers
%             (Optional) specifies channels
%
%
% OUTPUT ARGUMENTS
% rec         Record object
%
%
% See also
% K_SONAlignAndBin
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 09-May-2017 06:27:33




p = inputParser;
p.addRequired('smrname',@(x) ischar(x) && isrow(x) ...
    && exist(x,'file') && ismatched(x,'\.smr'));
p.addRequired('sRateNew',@(x) isscalar(x) && isreal(x) ...
    && x >0);
p.addOptional('channumbers',[],@(x) isvector(x) && all(x > 0) ...
    && all(fix(x) == x));
p.parse(smrname,sRateNew,varargin{:});

channumbers = p.Results.channumbers;

fid = fopen(smrname,'r') ;

chanlist = SONChanList(fid);
T_chanlist = struct2table(chanlist);
tfWfEv = T_chanlist.kind == 1 | T_chanlist.kind == 2 | T_chanlist.kind == 3;
TWfEv = T_chanlist(tfWfEv,:);

C = cell(length(channumbers),1);

for i = 1:length(channumbers)
    s = K_SONAlignAndBin(sRateNew,fid,channumbers(i));
    
    if ChanInfo.vf_structMarker(s)
        
        for j = 1:size(TWfEv,1)
            try
                s2 = K_SONAlignAndBin(sRateNew,fid,TWfEv.number(j));
                
                C{i} = MarkerChan(s,s2);
                break
            catch
                
            end
            
        end
    else
        
        C{i} = Chan.constructChan(s);

    end
    
    clear s s2
end

fclose(fid);


[~,filename,~] = fileparts(smrname);

rec = Record(C,'Name',filename);


end

