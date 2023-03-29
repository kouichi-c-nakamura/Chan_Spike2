classdef MetaEventChan < Chan
    %MetaEventChan class is an abstract class. It is a subclass of
    %Chan class and a superclass of EventChan and MarkerChan
    %classes.
    %
    % properties
    % ISI       length(ISI) == EventChan.Length + 1
    %
    %           ISI(1) == time interval between the beginning of Time and the
    %           first spike
    %
    %           ISI(2:end-1) == time interval between spikes
    %
    %           ISI(end) == time interval between the last spike and the end of
    %           Time
    %
    %           Note that if you only want to use genuine ISIs, you need to
    %           subtract ISI(2:end-1). ISI(0) and ISI(end) are useful in
    %           terms of ISI-based LTS burst detection etc, but should not
    %           be used for actual ISI statistics.
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 15-Aug-2017 15:25:31
    %
    % See Also 
    % Chan, Record, WaveformChan, EventChan,
    % MarkerChan
    
    properties (Abstract, Dependent = true)
        Data
    end
    
    properties (Dependent = true, SetAccess = private)
        ISI % Genuine ISIs, excluding silience before the first event and after the last events.
        %ISIplus % Genuine ISIs + intervals between time 0 and the first event and between the last event ant MaxTime().
        % ISIplus(0) and ISIplus(end) are useful in terms of ISI-based LTS burst detection etc, but should not be used for ISI statistics.
        
        InstantRate % Instantaneous firing rate in Hertz
        TimeStamps % Time stamps of events in Second.
        FiringRate % Mean firing rate of the whole 
        NSpikes % the number of spikes in the whole file
        Stats % Statistics of the events

    end
    
    methods
        
        function ISI = get.ISI(obj)
            %ISI  = get.ISI(obj)
            %
            % ISI as a column vector
            %   ISI(1:end) == time interval between spikes (i.e. interspike intervals)
            %
            % see also ISIplus
            
            if ~isempty(obj.Data)
                
                TimeStamps = obj.TimeStamps;
                
                if ~isempty(TimeStamps)
                    ISI = diff(TimeStamps);
                else
                    ISI = [];
                end
                
            else
                ISI = [];
            end
            
        end
        
        function InstantRate = get.InstantRate(obj)
            %InstantRate = get.InstantRate(obj)
            %
            % See Also MetaEventChan
            
            InstantRate = 1./obj.ISI(2:end-1);
            
        end
        
        function TimeStamps = get.TimeStamps(obj)
            %TimeStamps  = get.TimeStamps(obj)
            % TimeStamps as a double column vector
            %
            % See Also MetaEventChan
            
            if ~isempty(obj.Data) 
                data = obj.Data;
                % ind = find(data(:, 1)); %slow                
                % TimeStamps = obj.Start + (ind-1)*obj.SInterval;

                t = obj.time;
                TimeStamps = t(logical(data));
            else
                TimeStamps = [];
            end
        end
        
        function FiringRate = get.FiringRate(obj)
            
            FiringRate = obj.NSpikes/(obj.MaxTime - obj.Start);
            
        end
        
        function NSpikes = get.NSpikes(obj)
            %NSpikes = get.NSpikes(obj)
            % The number of spikes in the whole file
            %
            % See Also MetaEventChan
            
            if ~isempty(obj.Data)
                data = obj.Data;
                NSpikes = nnz(data(:, 1));          
            else
                NSpikes = [];
            end
        end
        
        function Stats = get.Stats(obj)
            %
            %
            %
            % See Also MetaEventChan, MetaEventChan.getstats
            
            if ~isempty(obj.Data)
                Stats = obj.getstats;
            else
                Stats = [];
            end
        end
        
        
        function h = plotCV2hist(obj)
            % h = plotCV2hist(obj)
            % plot CV2
            %
            % Holt GR, Softky WR, Koch C, Douglas RJ. 1996. Comparison of discharge
            % variability in vitro and in vivo in cat visual cortex neurons. J
            % Neurophysiol. 75:1806?814. PMID: 8734581
            %
            % See Also MetaEventChan
            
            hist(obj.Stats.ISI_CV2, 20);
            h = gca;
            xlabel('C_V_2 values');
            ylabel('Number of events');
            set(h, 'TickDir', 'out', 'Box', 'off');
        end
        
        function h = plotCV2vsISIpair(obj)
            % h = plotCV2vsISIpair(obj)
            % plot CV2
            %
            % Holt GR, Softky WR, Koch C, Douglas RJ. 1996. Comparison of discharge
            % variability in vitro and in vivo in cat visual cortex neurons. J
            % Neurophysiol. 75:1806?814. PMID: 8734581
            %
            % See Also MetaEventChan
            
            ISI = obj.ISI(2:end-1);
            
            meanISIpair = zeros(length(ISI) - 1, 1);
            for i = 1:(length(ISI) - 1)
                meanISIpair(i) = mean([ISI(i), ISI(i+1)]);
            end
            
            CV2 = obj.Stats.ISI_CV2;
            plot(meanISIpair, CV2, 'LineStyle', 'none', 'Marker', 'o');
            
            h = gca;
            ylabel('C_V_2 values');
            xlabel('Mean of ISI pair [sec]');
            set(h, 'TickDir', 'out', 'Box', 'off');
        end
        
        
        
        [ handles, results ] = plotPhaseHist( obj, waveform, varargin)
        
        function plotMeanFiringRate(obj, timewidth)
            %TODO
            % % The mean frequency is calculated at each event by counting the number
            % of events in the previous period set by Bin size. The result is measured
            % in units of events per second unless the Per minute box is checked. The
            % mean frequency at the current event time is given by:
            %
            % (n-1)/(te-tl)        if (te-t1) > tb/2 n/tb                if (te-t1) <=
            % tb/2
            %
            % where:
            %
            % tb is the bin size set, te is the time of the current event, t1 time of
            % the first event in the time range and n is the events in the time range
            %
            % A constant input event rate produces a constant output until there are
            % less than two events per time period. You should set a time period that
            % would normally hold several events.
            
        end
        
        function plotInstantRate(obj)
            %TODO easy to implement
        end
        
        function plotRateHistogram(obj, timewidth)
            %TODO
            %  Rate mode counts how many events fall in each time period set by the
            %  Time width field, and displays the result as a histogram. The result is
            %  not divided by the bin width. This form of display is especially useful
            %  when the event rate before an operation is to be compared with the event
            %  rate afterwards.
        end
        
    end
    
    methods (Access = private)
        stats = getstats(obj)
    end
    
end

