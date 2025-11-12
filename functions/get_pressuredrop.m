function pressuredrop = get_pressuredrop(mdot, rho, mu, K_total)
    % mdot - mass flow rate of nitrous (lb/s)
    % rho - density of nitrous (kg/m^3)
    % mu - absolute visocity of nitrous (Pa * s)
    % K_total - total K value of fittings and valves
    
    %% Convert mdot from lb/s to kg/s
    mdot = mdot * 0.45359237; 

    %% Calculate fluid velocity
    v = (4 * mdot) / (pi * rho * D_hose^2); % m/s

    %% Calculate pressure loss from pipes
    % Define Constants
    d = 10.2108; % inner diameter of pipe(mm) 
    D = d / 1000; % inner diameter of pipe (m)
    L = ; % length of piping (m)
    epsilon = 0.015; % absolute roughness of stainless steel pipe (mm)

    % Calculate Reynolds Number
    Re = (D * v * rho) / mu;

    % Calculate friction factor f with Serghide Approximation    
    f = get_friction_factor(d, epsilon, Re);

    % Calculate equivalent length of of all fittings/valves
    L_eq = (K_total * D) / f;
    
    % Calculate total effective length 
    L_effective = L + L_eq;

    % Calculate pressure loss from pipes
    pressuredrop = (f * L_effective * v^2 * rho) / (D * 2);
    
end

function f = get_friction_factor(d, epsilon, Re)
    
    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);

end
