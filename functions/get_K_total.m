%% Calculates total K-loss factor
% View full documentation here:

function K_total = get_K_total(all_fittings, Re, D)
    % all_fittings = string array with list of fitting and valve names
    % Re = Reynolds Number
    % D = internal diameter of pipe (m)

    % Calculate Total K Value
    K_total = 0;

    for fitting = all_fittings
        K_total = K_total + get_K(fitting, Re, D);
    end

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
        otherwise
            error("Unknown fitting type: %s", fitting_type);
    end

    D_in = D * 39.37;
    K_fitting = (K_1 / Re) + K_infinity * (1 + (1 / (D_in))); % K values are given with D in inches

end