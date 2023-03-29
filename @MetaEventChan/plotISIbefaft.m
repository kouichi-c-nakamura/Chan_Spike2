function [h, figh] = plotISIbefaft(obj)
if isempty(obj.ISI)
    return;
end

isi = obj.ISI(2:end-1);

isibef = isi(1:end-1);
isiaft = isi(2:end);

figh = figure;

h = loglog(isibef.*1000, isiaft.*1000, 'LineStyle', 'none', 'Marker', 'o');
xlabel('ISI before [ms]');
ylabel('ISI after [ms]');
set(gca, 'Box', 'off', 'TickDir', 'out');
end