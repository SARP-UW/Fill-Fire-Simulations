%density_new: kg/m3
%energy_old: kJ/kg
%temperature_old: K

function [t, x] = state_density(density_new, energy_old, temperature_old)

    u_SI = energy_old * 1000; %kJ/kg to J/kg
    rho_SI = density_new;

    try
        t = py.CoolProp.CoolProp.PropsSI('T', 'D', rho_SI, 'U', u_SI, 'N2O'); %temp cal

        x = py.CoolProp.CoolProp.PropsSI('Q', 'D', rho_SI, 'U', u_SI, 'N2O'); %quality cal
        
        if x < 0; x = 0; elseif x > 1; x = 1; end %limit quality from 0 to 1
        
    catch
        fprintf('Warning: CoolProp convergence failed. Returning old temperature.\n'); %error code
        t = temperature_old;
        x = 0; % default
    end
end


%{
    % Get path to the data folder and access to the vapor and liquid property excel tables 
    this_file = mfilename('fullpath');
    this_folder = fileparts(this_file);
    main_folder = fileparts(this_folder);
    addpath(fullfile(main_folder, 'functions'));

    % Get initial index to track the row in the excel tables that corresponds to the old temperature
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
    x = ((v_t - v_f)/(v_g - v_f) + (u_t - u_f)/(u_g - u_f)) / 2;
    t_old = closest_row_liquid.Temperature_K;
    
    % Initialize return variables
    final_t = temperature_old;
    final_x = x;
    
    keep_iterating1 = true;

    % Ensure that the initial difference is positive in order to ensure the
    % solver is working properly
    if difference_old < 0 && keep_iterating1
        
        keep_iterating = false;
        
        idx = idx + 1;
        closest_row_liquid = liquid_properties_table(idx, :);
        closest_row_vapor = vapor_properties_table(idx, :);

        % Calculate corresponding u, v with this new, higher temperature
        v_f = 1 / closest_row_liquid.Density_kg_m3;
        v_g = 1 / closest_row_vapor.Density_kg_m3;
        u_f = closest_row_liquid.Internal_Energy_kJ_kg;
        u_g = closest_row_vapor.Internal_Energy_kJ_kg;
        
        % Calculate difference for solver
        difference = (v_t - v_f)/(v_g - v_f) - (u_t - u_f)/(u_g - u_f);
        final_x = ((v_t - v_f)/(v_g - v_f) + (u_t - u_f)/(u_g - u_f)) / 2;
        t = closest_row_liquid.Temperature_K;

        % If the difference now flips to positive, compute the temperature
        % using the old difference
        if difference > 0
            total_difference = difference - difference_old;
            delta_t = t - t_old;
            final_t = t_old + (-difference_old/total_difference) * (delta_t);
            keep_iterating1 = false;
        end 

        difference_old = difference;
        t_old = t;
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
        final_x = ((v_t - v_f)/(v_g - v_f) + (u_t - u_f)/(u_g - u_f)) / 2;
        t = closest_row_liquid.Temperature_K;

        % If the difference now flips to negative, compute the temperature
        % using the old difference
        if difference < 0
            total_difference = difference_old - difference;
            delta_t = t_old - t;
            final_t = t + (-difference/total_difference) * (delta_t);
            keep_iterating = false;
        end

        difference_old = difference;
        t_old = t;
    end

    t = final_t;
    x = final_x;

end
%}