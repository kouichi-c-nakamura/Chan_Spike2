function [wb] = K_waitbar(i,N,wbmsg,wb,varargin)
% Customized waitbar function. It takes 20~50 msec to update for each cycle.
% Note that it's relatively expensive with regard to time consumption.
% 
% wb = K_waitbar(i, N, wbmsg, [])            % for initialization
% wb = K_waitbar(i, N, wbmsg, wb)            % to show wait bar
% wb = K_waitbar(i, N, wbmsg, wb, winstyle)  % to set 'WindowStyle'
% close(wb)                                  % to close waitbar
%
%
% INPUT ARGUMENTS
% wb      handle of the waitbar
%         Use "wb = []" for the initialization
%         Use "close(wb)" to close the waitbar figure
%
% i       the current index, must be 0 or positive
% N       the goal index, must be positive
% wbmsg   string above the waitbar
% wb      use empty wb = [] for initializaiton outside the loop
%         handle for the waitbar
%
% OPTION
% winstyle  'modal' (default) | 'normal' | 'docked'
%           To control 'WindowStyle' property of waitbar window.
%
% OUTPUT ARGUMENT
% wb      handle of the waitbar
%
% EXAMPLE:
%
% wb = [];
% for i = 1:N
%    wbmsg = sprintf('in progress: %.1f%%', i/N*100) ;
%    wb = K_waitbar(i, N, wbmsg, wb);
%
%    .......
% end
% close(wb)

%% Parse

narginchk(4,5);

[i, N, wbmsg, wb, winstyle] = local_parser(i, N, wbmsg, wb, varargin{:});
 

%% Job

% wbmsg = sprintf('In progress: %s', filename);
if isempty(wb)
    wb = waitbar(i/N, wbmsg);
    set(findobj(wb, 'Type', 'Patch'), 'FaceColor', 'cyan', 'EdgeColor', 'cyan');
    set(findobj(wb, 'Type', 'Line'), 'Color', 'cyan');
    set(findall(wb,'type','text'),'Interpreter','none');
    
    set(wb, 'WindowStyle', winstyle);

elseif  ~isempty(wb)
    
    clear p;
    p = inputParser;
    
    vfwb = @(x) isempty(x) ||...
        isscalar(x) && isnumeric(x) && x > 0;
    addRequired(p, 'wb', vfwb);
    waitbar(i/N, wb, wbmsg);
end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [i, N, wbmsg, wb, winstyle] = local_parser(i, N, wbmsg, wb, varargin)

p = inputParser;
vfi = @(x) ~isempty(x) &&...
    isscalar(x) &&...
    x >= 0;
p.addRequired('i', vfi);

vfN = @(x) ~isempty(x) &&...
    isscalar(x) &&...
    x > 0;
p.addRequired('N', vfN);

vfwbmsg = @(x) isempty(x) ||...
    ischar(x) && isrow(x);
p.addRequired('wbmsg', vfwbmsg);

if verLessThan('matlab','8.4.0') % slow
    vfwb = @(x) isempty(x) ||...
        isscalar(x) && isnumeric(x) && x > 0;
else
    vfwb = @(x) isempty(x) ||...
        isscalar(x) && isa(x, 'matlab.ui.Figure');
end

p.addRequired('wb', vfwb);

p.addOptional('winstyle','modal',@(x) ischar(x) && isrow(x) && ...
    ismember(x,{'normal','modal','docked'}));

p.parse(i, N, wbmsg, wb, varargin{:});

winstyle = p.Results.winstyle;

end 