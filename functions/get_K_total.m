%% Calculates total K-loss factor
% View full documentation here:

function K_total = get_K_total(all_fittings, Re, D)
    % all_fittings = string array with list of fitting and valve names
    % Re = Reynolds Number
    % D = internal diameter of pipe (m)

    % Calculate Total K Value
    K_total = 0;

    for i = 1:numel(all_fittings)
        fitting = all_fittings(i);
        K_total = K_total + get_K(fitting, Re, D);
    end

end

function K_fitting = get_K(fitting_type, Re, D)
% calculate K_fitting depending on fitting_type
    switch fitting_type
        case "elbow_90_curve_SR_thread"
            K_1 = 800;
            K_infinity = 0.25;
        case "elbow_90_ curve_SR_flange"
            K_1 = 800;
            K_infinity = 0.25;
        case "elbow_90_curve_LR"
            K_1 = 800;
            K_infinity = 0.2;
        case "elbow_90_mitered_singleweld"
            K_1 = 1000;
            K_infinity = 1.15;
        case "elbow_90_mitered_doubleweld"
            K_1 = 800;
            K_infinity = 0.35;
        case "elbow_90_mitered_tripleweld"
            K_1 = 800;
            K_infinity = 0.3;
        case "elbow_45_SR"
            K_1 = 500;
            K_infinity = 0.2;
        case "elbow_45_LR"
            K_1 = 500;
            K_infinity = 0.15;
        case "elbow_45_mitered_singleweld"
            K_1 = 500;
            K_infinity = 0.25;
        case "elbow_45_mitered_doubleweld"
            K_1 = 500;
            K_infinity = 0.15;
        case "180_SR_screwed"
            K_1 = 1000;
            K_infinity = 0.6;
        case "180_SR_flanged"
            K_1 = 1000;
            K_infinity = 0.35;
        case "180_LR"
            K_1 =1000;
            K_infinity = 0.3;
        case "t_elbow_SR_screwed"
            K_1 = 500;
            K_infinity = 0.7;
        case "t_elbow_SR_flanged"
            K_1 = 800;
            K_infinity = 0.8;
        case "t_elbow_LR"
            K_1 = 800;
            K_infinity = 0.4;
        case "t_elbow_stub"
            K_1 = 1000;
            K_infinity = 1;
        case "t_run_screwed"
            K_1 = 200;
            K_infinity = 0.1;
        case "t_run_flanged"
            K_1 = 150;
            K_infinity = 0.05;
        case "t_run_stub"
            K_1 = 100;
            K_infinity = 0;
        case "gate_beta=1"
            K_1 = 300;
            K_infinity = 0.1;
        case "gate_beta=0.9"
            K_1 = 500;
            K_infinity = 0.15;
        case "gate_beta=0.8"
            K_1 = 1000;
            K_infinity = 0.25;
        case "ball_beta=1"
            K_1 = 300;
            K_infinity = 0.1;
        case "ball_beta=0.9"
            K_1 = 500;
            K_infinity = 0.15;
        case "ball_beta=0.8"
            K_1 = 1000;
            K_infinity = 0.25;
        case "plug_beta=1"
            K_1 = 300;
            K_infinity = 0.1;
        case "plug_beta=0.9"
            K_1 = 500;
            K_infinity = 0.15;
        case "plug_beta=0.8"
            K_1 = 1000;
            K_infinity = 0.25;
        case "globe_standard"
            K_1 = 1500;
            K_infinity = 4;
        case "globe_angle"
            K_1 = 1000;
            K_infinity = 2;
        case "diaphragm_dam"
            K_1 = 1000;
            K_infinity = 2;
        case "butterfly"
            K_1 = 800;
            K_infinity = 0.25;
        case "lift"
            K_1 = 2000;
            K_infinity = 10;
        case "swing"
            K_1 = 1500;
            K_infinity = 1.5;
        case "tilting_disk"
            K_1 = 1000;
            K_infinity = 0.5;
        case "cross_run" % approximate as two t_pass
            K_1 = 2 * 150;
            K_infinity = 1 * 0.05;
        case "pipe_exit"
            K_fitting = 1.0;
            return
        otherwise
            error("Unknown fitting type", fitting_type);
    end

    D_in = D * 39.37;
    K_fitting = (K_1 / Re) + K_infinity * (1 + (1 / (D_in))); % K values are given with D in inches

end