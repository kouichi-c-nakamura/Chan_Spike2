classdef ChanInfo_6OHDA_KCN < ChanInfo
    
    
    properties
        RecordKind@RecordKind = RecordKind.Unspecified; % type of data in terms of the content
        NucKind@NucKind = NucKind.Unspecified;           % nucleus where the data was recorded from
        Coordinate = [0,0,0];                            % [caudal, dorsal, ventral]
    end
    
    methods
        function obj = ChanInfo_6OHDA_KCN(varargin)
            
            obj = obj@ChanInfo(varargin{:});
                            
        end
    end
end