% This function gets the quality based off an intensive property and
% temperature 

% Arguments: t = temperature in Kelvin, property = string of header name in
% liquid_properties excel, value = value of said property: proper units

function quality = get_quality(t, property, value)
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

    delta_property_vapor = row_vapor2.(property) - row_vapor1.(property);
    delta_property_liquid = row_liquid2.(property) - row_liquid1.(property);
    delta_t = row_vapor2.Temperature_K - row_vapor1.Temperature_K;
    property_g = row_vapor1.(property) + (t - row_vapor1.Temperature_K) * delta_property_vapor / delta_t;
    property_f = row_liquid1.(property) + (t - row_liquid1.Temperature_K) * delta_property_liquid / delta_t;
    quality = (value - property_f) / (property_g - property_f);
end