function [xmin, xmax, ymin, ymax] = get_ranges(time_data, signal_data, xmin, xmax, ymin, ymax)

time_plot = time_data;
actual_output_plot = signal_data;

xmin1 = min(time_plot);
if xmin1 < xmin
    xmin = xmin1 + (xmin1*0.1);
else
    %do nothing
end

xmax1 = max(time_plot);
if xmax1 > xmax
    xmax = xmax1 + (xmax1*0.1);
else
    %do nothing
end

ymin1 = min(actual_output_plot);
if ymin1 < ymin
    ymin = ymin1 + (ymin1*0.1);
else
    %do nothing
end

ymax1 = max(actual_output_plot);
if ymax1 > ymax
    ymax = ymax1 + (ymax1*0.1);
else
    %do nothing
end
end