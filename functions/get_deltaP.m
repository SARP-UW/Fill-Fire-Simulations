function deltaP = get_deltaP(v, rho, mu, all_fittings)
    %% Define Variables (will put in documentation later)
    % v - average velocity of flow (m/s)
    % rho - density of nitrous (kg/m^3)
    % mu - absolute visocity (Pa * s)
    % D - inner diameter (m)
    % d - inner diameter (mm)
    % L - length of piping
    % L_eq - equivalent length of fittings/valves
    % L_total_eq - total equivalent length
    % Re - reynolds number
    % all_fittings - string array of all the fittings
    
    %% Define Constants
    d = 9; % inner diameter (mm) 
    D = d / 1000; % inner diameter (m)
    L = ; % length of piping
    epsilon = 0.015; % absolute roughness of stainless steel pipe
    
    %% Calculate Reynolds Number
    Re = (D * v * rho) / mu;

    %% Calculate Total K Value
    K_total = 0;

    for x = all_fittings
        K_total = K_total + get_K(x, Re, D);
    end


    %% Calculate friction factor f with Serghide Approximation
    d = D * 1000; % Inner Diameter (mm)
    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);
    
    %% Calculate equivalent length of of all fittings/valves
    L_eq = (K_total * D) / f;
    
    %% Calculate total equivalent length
    L_total_eq = L + L_eq;
    
    %% Calculate total pressure loss
    deltaP = (f * L_total_eq * v^2 * rho) / (D * 2);

end

function K_fitting = get_K(fitting_type, Re, D)
% calculate K_fitting depending on fitting_type
    switch fitting_type
        case "t_pass"
            K_1 = 150;
            K_infinity = 0.05;
        case "cross_pass" % approximate as two t_pass
            K_1 = 2 * 150;
            K_infinity = 1 * 0.05;
        case "ball"
            K_1 = 300;
            K_infinity = 0.1;

    K_fitting = (K_1 / Re) + K_infinity * (1 + (1 / (D * 39.37))); % K values are given with D in inches

end


