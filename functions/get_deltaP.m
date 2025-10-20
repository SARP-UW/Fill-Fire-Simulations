function deltaP = get_deltaP(mdot, rho, mu, all_fittings)
    % mdot - mass flow rate of nitrous (lb/s)
    % rho - density of nitrous (kg/m^3)
    % mu - absolute visocity of nitrous (Pa * s)
    % all_fittings - string array of all the fittings
    
    %% Convert mdot from lb/s to kg/s
    mdot = mdot * 0.45359237; 

    %% Calculate pressure loss from pipes
    deltaP_pipes = get_deltaP_pipes(mdot, rho, mu, all_fittings);

    %% Calculate pressure loss from hose
    deltaP_hose = get_deltaP_hose(mdot, rho, mu);

    %% Calculate total deltaP
    deltaP = deltaP_pipes + deltaP_hose;
    
end

function deltaP_pipes = get_deltaP_pipes(mdot, rho, mu, all_fittings)
    
    %% Define Constants
    d = 10.2108; % inner diameter of pipe(mm) 
    D = d / 1000; % inner diameter of pipe (m)
    L = ; % length of piping (m)
    epsilon = 0.015; % absolute roughness of stainless steel pipe

    %% Calculate velocity of fluid
    v = (4 * mdot) / (pi * rho * D^2); % m/s

    %% Calculate Reynolds Number
    Re = (D * v * rho) / mu;

    %% Calculate Total K Value
    K_total = 0;

    for i = 1:length(all_fittings)
        K_total = K_total + get_K(all_fittings(i), Re, D);
    end

    %% Calculate friction factor f with Serghide Approximation    
    f = get_friction_factor(d, epsilon, Re);

    %% Calculate equivalent length of of all fittings/valves
    L_eq = (K_total * D) / f;
    
    %% Calculate total effective length 
    L_effective = L + L_eq;

    %% Calculate pressure loss from pipes
    deltaP_pipes = (f * L_effective * v^2 * rho) / (D * 2);

end

function deltaP_hose = get_deltaP_hose(mdot, rho, mu)
    d_pipe = 10.2108; % inner diameter of pipe (mm)
    d_hose = 8.80; % inner diameter of hose (mm) 
    D_hose = d_hose / 1000; % inner diameter of hose(m)
    L_pre = 30 / 3.281; % length of hose before RF stand (m)
    L_post = 4 / 3.281; % length of hosing after RF stand (m)
    epsilon = 0.038; % absolute roughness of rubber hose (mm)
    
    % Calculate fluid velocity
    v = (4 * mdot) / (pi * rho * D_hose^2); % m/s

    % Calculate Reynolds Number
    Re = (D_hose * v * rho) / mu;

    % Calculate friction factor f with Serghide Approximation    
    f = get_friction_factor(d_hose, epsilon, Re);

    % Calculate pressure losses from connections
    K = ; % K bottle valve to hose

    if d_hose > d_pipe
        K = K + 0.5 * (1 - (d_hose ^ 2) / (d_pipe ^ 2))^2; % hose to RF
        K = K + (1 - (d_pipe ^ 2) / (d_hose ^ 2))^2; % RF to hose
    elseif d_hose < d_pipe
        K = K + (1 - (d_hose ^ 2) / (d_pipe ^ 2))^2; % hose to RF
        K = K + 0.5 * (1 - (d_pipe ^ 2) / (d_hose ^ 2))^2; % RF to hose
    end

    % Calculate equivalent length of connections
    L_eq = (K * D_hose) / f;

    % Calculate total equivalent length of hosing and connections
    L_total_eq = L_pre + L_post + L_eq;

    % Calculate pressure loss from hose and connections
    deltaP_hose = (f * L_total_eq * v^2 * rho) / (D_hose * 2);
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
        case "t_elbow"
            K_1 = 800;
            K_infinity = 0.8;
        case "pipe_exit"
            K_fitting = 1.0;
            return
    end

    K_fitting = (K_1 / Re) + K_infinity * (1 + (1 / (D * 39.37))); % K values are given with D in inches

end

function f = get_friction_factor(d, epsilon, Re)
    
    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);

end
