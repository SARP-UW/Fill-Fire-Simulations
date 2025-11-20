function newFigure(i, x_max, y_max, options)
% This function creates a new figure with the specified parameters.
    arguments
        i double
        x_max double
        y_max double
        % These labels were originally for AMATH 301 written homework 1
        options.title (1,:) string = "Population Density vs. Time"
        options.xaxis (1,:) string = "Time"
        options.yaxis (1,:) string = "Population Density"
        options.xLat (1,1) double = 0
        options.yLat (1,1) double = 0
        options.titleLat (1,1) double = 0
        options.int double = 1
        options.x_min double = 0;
        options.y_min double = 0;
        options.gridOn double = 0;
    end
    figure(i);
    hold on;
    ylim([options.y_min,y_max]);
    xlim([options.x_min,x_max]);
    if options.xLat
        xlabel(options.xaxis, 'Interpreter', 'latex', 'FontSize', 25);
    else
        xlabel(options.xaxis, 'FontSize', 25);
    end
    if options.yLat
        ylabel(options.yaxis, 'Interpreter', 'latex', 'FontSize', 25);
    else
        ylabel(options.yaxis, 'FontSize', 25);
    end
    if options.titleLat
        title(options.title, 'Interpreter', 'latex', 'FontSize', 20);
    else
        title(options.title, 'FontSize', 20);
    end
    if options.gridOn
        xticks(0:options.int:x_max);
        grid("on");
    end
    % For AMATH 301
    % assignin('base', 'g', 0);
    % assignin('base', 'b', 1);
end