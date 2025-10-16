function deltaP = get_deltaP(v, rho, mu, all_fittings)
    %% Define Variables (will put in documentation later)
    % v - average velocity of nitrous flow (m/s)
    % rho - density of nitrous (kg/m^3)
    % mu - absolute visocity of nitrous (Pa * s)
    % D - pipe inner diameter (m)
    % d - pipe inner diameter (mm)
    % L - length of piping
    % L_eq - equivalent length of fittings/valves
    % L_total_eq - total equivalent length
    % Re - reynolds number
    % all_fittings - string array of all the fittings
        % valid arguments = "t_pass" "cross" "ball"
    
    %% Define Constants
    d = 10.2108; % inner diameter (mm) 
    D = d / 1000; % inner diameter (m)
    L = ; % length of piping (m)
    epsilon = 0.015; % absolute roughness of stainless steel pipe
    
    %% Calculate Reynolds Number
    Re = (D * v * rho) / mu;

    %% Calculate Total K Value
    K_total = 0;

    for x = all_fittings
        K_total = K_total + get_K(x, Re, D);
    end


    %% Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);
    
    %% Calculate equivalent length of of all fittings/valves
    L_eq = (K_total * D) / f;
    
    %% Calculate total equivalent length
    L_total_eq = L + L_eq;

    %% Calculate pressure loss from hose
    deltaP_hose = get_deltaP_hose(v, rho, mu, d);
    
    %% Calculate total pressure loss
    deltaP = (f * L_total_eq * v^2 * rho) / (D * 2);

end

function deltaP_hose = get_deltaP_hose(v, rho, mu, d)
    % d - inner diameter of pipe (mm)
    d_hose = ; % inner diameter of hose (mm) 
    D_hose = d / 1000; % inner diameter of hose(m)
    L_pre = 30 / 3.281; % length of hose before RF stand (m)
    L_post = 4 / 3.281; % length of hosing after RF stand (m)
    epsilon = 0.038; % absolute roughness of rubber hose (mm)
    
    % Calculate Reynolds Number
    Re = (D_hose * v * rho) / mu;

    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d_hose)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d_hose)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d_hose)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);

    % Calculate pressure losses from connections
    K = ;% K bottle valve to hose

    if d_hose > d
        K = K + 0.5 * (1 - (d_hose ^ 2) / (d ^ 2))^2; % hose to RF
        K = K + (1 - (d ^ 2) / (d_hose ^ 2))^2; % RF to hose
    else if d_hose < d
        K = K + (1 - (d_hose ^ 2) / (d^2))^2; % hose to RF
        K = K + 0.5 * (1 - (d ^ 2) / (d_hose ^ 2))^2; % RF to hose
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


