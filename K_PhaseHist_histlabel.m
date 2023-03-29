function K_PhaseHist_histlabel(results, handles, titlelin, titlecirc, varargin)
% K_PhaseHist_histlabel adds summary data as text into the specfied axes (handles).
% Works with the output of K_PhaseHist
%
% K_PhaseHist_histlabel(results, handles, titlelin, titlecirc)
% K_PhaseHist_histlabel(results, handles, titlelin, titlecirc, fieldname)
%
% INPUT ARGUMENTS
% results         Output of K_PhaseHist
% handles         Output of K_PhaseHist
% titlelin        String for title of the linear phase histogram
% titlecirc       String for title of the circular phase histogram
%
% OPTIONAL
% fieldname       'unitrad' | 'eegrad'
%
% OPTIONAL PARAM/VALUE PAIRS
%
% 'titleparams',  cell row vector containing optional param/val pairs for title
%
% 'textparams',   cell row vector containing optional param/val pairs for title
%
%
% See also
% K_PhaseHist
% K_plotLinearPhaseHist 
% K_plotLinearPhaseHist_S  (to directly use output of K_PhaseHist as an input argument)
% K_PhaseHist_histlabel    (add summary text to the plots made by K_PhaseHist)
% K_plotCircPhaseHist_one, K_plotCircPhaseHist_group (for circular plots)
% K_plotColorPhaseHist     (heatmap representation of phase coupling)
% K_ECDFforRayleigh        (ECDF-based correction for Rayleigh's uniformity test)
% K_PhaseHist_test         (UnitTest)
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 05-May-2017 09:26:34




p = inputParser;
p.addRequired('results');
p.addRequired('handles');
p.addRequired('titlelin');
p.addRequired('titlecirc');
p.addOptional('fieldname', 'unitrad', @(x) ismember(x, {'unitrad', 'eegrad'}));
p.addParameter('titleparams', {}, @(x) iscell(x) && isrow(x));
p.addParameter('textparams', {}, @(x) iscell(x) && isrow(x));

p.parse(results, handles, titlelin, titlecirc, varargin{:});

fieldname = p.Results.fieldname;
titleparams = p.Results.titleparams;
textparams = p.Results.textparams;


if ~isempty(results.(fieldname))

    thestr = sprintf(['Rayleigh'' test: p = %.3f\n',...
        'Cicrular mean: %.2f ', char(177), ' %.2f', char(176), '\n'], ...
        results.(fieldname).raylecdf,...
        rad2ang(results.(fieldname).cmean),...
        rad2ang(results.(fieldname).cstd));
          
else
    
   return; 
end



if ~isempty(handles.hlin)
    
    axes(handles.hlin.sub.axh);
    
    if ~isempty(titleparams)
		title(handles.hlin.main.axh, titlelin,...
			'Units', 'normalized', 'Position', [0.5, 1.16, 0],...
			titleparams{:});
	else
		title(handles.hlin.main.axh, titlelin,...
			'Units', 'normalized', 'Position', [0.5, 1.16, 0]);
	end
    
    axes(handles.hlin.main.axh);
       
	if ~isempty(textparams)
		text(0.95, 0.95, thestr,...
			'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
			'Units', 'normalized',...
			textparams{:});
    else
		text(0.95, 0.95, thestr,...
			'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
			'Units', 'normalized');    
    end
    
end

if ~isempty(handles.hcirc)
    
	if ~isempty(titleparams)
		title(handles.hcirc.axh, titlecirc,...
			'HorizontalAlignment', 'center', ...
			'Visible', 'on', 'Units', 'normalized',  'Position', [0.5, 1, 0],...
			titleparams{:});
	else
		title(handles.hcirc.axh, titlecirc,...
			'HorizontalAlignment', 'center', ...
			'Visible', 'on', 'Units', 'normalized',  'Position', [0.5, 1, 0]);

	end
    
    axes(handles.hcirc.axh);
	if ~isempty(textparams)
		text(1, 0, thestr, ...
			'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
			'Units', 'normalized',...
			textparams{:});
	else
		text(1, 0, thestr, ...
			'HorizontalAlignment', 'right', 'VerticalAlignment','top',...
			'Units', 'normalized');

	end
    
end

end