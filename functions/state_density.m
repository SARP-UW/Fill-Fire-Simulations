%density_new: kg/m3
%energy_old: kJ/kg
%temperature_old: K

function output = state_density(density_new, energy_old, temperature_old)
    % Get path to the data folder and access to the vapor and liquid property excel tables 
    this_file = mfilename('fullpath');
    this_folder = fileparts(this_file);
    main_folder = fileparts(this_folder);
    liquid_properties_table = readtable(fullfile(main_folder, 'data', 'liquid_properties.xlsx'));
    vapor_properties_table = readtable(fullfile(main_folder, 'data', 'vapor_properties.xlsx'));

    % Get initial index to track the row in the excel tables that
    % corresponds to the old temperature
    [~, idx] = min(abs(liquid_properties_table.Temperature_K - temperature_old));
    closest_row_liquid = liquid_properties_table(idx, :);
    closest_row_vapor = vapor_properties_table(idx, :);

    % Define the new total state of the tank
    v_t = 1 / density_new;
    u_t = energy_old;
    
    % This variable tells the loop to stop once the value of quality
    % converges
    keep_iterating = true;

    % Start off the loop with assuming the temperature didn't drop at all,
    % then find corresponding u, v
    v_f = 1 / closest_row_liquid.Density_kg_m3;
    v_g = 1 / closest_row_vapor.Density_kg_m3;
    u_f = closest_row_liquid.Internal_Energy_kJ_kg;
    u_g = closest_row_vapor.Internal_Energy_kJ_kg;

    % Find the initial difference in the solver, as well as the temperature
    difference_old = (v_t - v_f)/(v_g - v_f) - (u_t - u_f)/(u_g - u_f);
    t_old = closest_row_liquid.Temperature_K;
    
    % Initialize return variable
    final_t = temperature_old;

    % Ensure that the initial difference is positive in order to ensure the
    % solver is working properly
    if difference_old < 0
        error("Thermo solver failed: Initial iteration not negative")
    end

    while keep_iterating
        % Drop the temperature one row on the property tables
        idx = idx - 1;
        closest_row_liquid = liquid_properties_table(idx, :);
        closest_row_vapor = vapor_properties_table(idx, :);

        % Calculate corresponding u, v with this new, lower temperature
        v_f = 1 / closest_row_liquid.Density_kg_m3;
        v_g = 1 / closest_row_vapor.Density_kg_m3;
        u_f = closest_row_liquid.Internal_Energy_kJ_kg;
        u_g = closest_row_vapor.Internal_Energy_kJ_kg;
        
        % Calculate difference for solver
        difference = (v_t - v_f)/(v_g - v_f) - (u_t - u_f)/(u_g - u_f);
        t = closest_row_liquid.Temperature_K;

        % If the difference now flips to negative, compute the temperature
        % using the old difference
        if difference < 0
            total_difference = difference_old - difference;
            delta_t = t - t_old;
            final_t = t + (difference/total_difference) * (delta_t);
            keep_iterating = false;
        end

        difference_old = difference;
        t_old = t;
    end
    
    output = final_t;

end