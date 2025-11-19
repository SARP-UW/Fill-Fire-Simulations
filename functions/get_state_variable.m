% t = Temperature in K
% phase = f, g, x (for liquid or gas say "g" and "f", for saturated liquid use x = 0.9 (or whatever the quality is))
% variable = variable for reference (ref. Excel sheet for headers)

function output = get_state_variable(t, phase, variable)
    this_file = mfilename('fullpath');
    this_folder = fileparts(this_file);
    main_folder = fileparts(this_folder);
    liquid_properties_table = readtable(fullfile(main_folder, 'data', 'liquid_properties.xlsx'));
    vapor_properties_table = readtable(fullfile(main_folder, 'data', 'vapor_properties.xlsx'));
    idx = find(liquid_properties_table.Temperature_K > t, 1, 'first');
    row_liquid2 = liquid_properties_table(idx, :);
    row_vapor2 = vapor_properties_table(idx, :);
    row_liquid1 = liquid_properties_table(idx - 1, :);
    row_vapor1 = vapor_properties_table(idx - 1, :);
    phase = string(phase);

    if (phase == "g")
        delta_t = row_vapor2.Temperature_K - row_vapor1.Temperature_K;
        delta_variable = row_vapor2.(variable) - row_vapor1.(variable);
        output = row_vapor1.(variable) + (t - row_vapor1.Temperature_K) * delta_variable / delta_t;
    elseif (phase == "f")
        delta_t = row_liquid2.Temperature_K - row_liquid1.Temperature_K;
        delta_variable = row_liquid2.(variable) - row_liquid1.(variable);
        output = row_liquid1.(variable) + (t - row_liquid1.Temperature_K) * delta_variable / delta_t;
    else 
        phase = double(phase);
        delta_t = row_liquid2.Temperature_K - row_liquid1.Temperature_K;
        delta_variable_liquid = row_liquid2.(variable) - row_liquid1.(variable);
        delta_variable_vapor = row_vapor2.(variable) - row_vapor1.(variable);
        delta_variable = delta_variable_vapor * phase + delta_variable_liquid * (1 - phase);
        variable_1 = row_vapor1.(variable) * phase + row_liquid1.(variable) * (1 - phase);
        output = variable_1 + (t - row_liquid1.Temperature_K) * delta_variable / delta_t;
    end

end