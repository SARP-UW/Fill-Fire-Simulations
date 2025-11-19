function mdot_flow = get_mdot_fill(P1, P2, rho, mu)
    % P1 - upstream pressure (Pa)
    % P2 - downstream pressure (Pa)
    % rho - density (kg/m^3)
    % mu - absolute viscosity (uPa s)

    %% Define characteristics from input sheet
    path = fullfile("..", "data", "line_properties.xlsx");
    T = readcell(path);
    
    L = [T{4,2}, T{9,2}, T{13,2}];
    L = L ./ 3.281; % Length of tubings (m)
    D = [T{5,2}, T{10,2}, T{14,2}];
    D = D ./ 39.37; % Inner diameter of tubings (m)
    epsilon = [T{6,2}, T{11,2}, T{15,2}]; % Absolute roughness of pipes (mm)
    Cv = T{7,2}; % K-bottle flow coefficient
    mu = mu * 1e-6; % convert micropascals*s to Pascals*s

    rf_fittings = string(T(3:end, 3)); % String array of all fittings on the RF stand
    rf_fittings = rf_fittings(~ismissing(rf_fittings));
    rf_fittings = rf_fittings(:);
    
    %% Calculate mdot
    deltaP = P1 - P2;

    diff = @(v) deltaP - guess_deltaP(max(v, 1e-6), rho, mu, L, D, epsilon, Cv, rf_fittings);

    vmin = 0.001;
    vmax = 100;

    v_actual = fzero(diff, [vmin, vmax]);

    mdot_flow = v_actual * rho * pi * D(1) ^ 2 / 4;
end

function guess = guess_deltaP(v_guess, rho, mu, L, D, epsilon, Cv, rf_fittings)
    %% Section 1
    A_1 = pi * D(1)^2 / 4; % cross sectional area of section 1 in m^2
    v_1 = v_guess; % v in section 1

    Re_1 = (D(1) * v_1 * rho) / mu;
    f_1 = get_friction_factor(D(1), epsilon(1), Re_1);

    d_mm = D(1) * 1000;
    K_1 = 2.148 * (10 ^ -3) * (d_mm ^ 4) / (Cv ^ 2); % Convert Cv to a resistance coefficient K
    
    deltaP_1 = ( (rho * v_1^2) / 2) * ( (f_1 * L(1) / D(1)) + K_1);
 
    %% Section 2
    A_2 = pi * D(2)^2 / 4; % cross sectional area of section 2 in m^2
    v_2 = v_1 * A_1 / A_2; % v in section 2
    Re_2 = (D(2) * v_2 * rho) / mu;
    f_2 = get_friction_factor(D(2), epsilon(2), Re_2);

    K_2 = 0;
    % K from diameter change
    if D(2) > D(1)
        K_2 = K_2 + (1 - (D(1) ^ 2 ) / (D(2) ^ 2)) ^ 2;
    else
        K_2 = K_2 + 0.5 * (1 - (D(1) ^ 2 ) / (D(2) ^ 2)) ^ 2;
    end
    K_2 = K_2 + get_K_total(rf_fittings, Re_2, D(2));

    deltaP_2 = ( (rho * v_2^2) / 2) * ( (f_2 * L(2) / D(2)) + K_2);


    %% Section 3
    A_3 = pi * D(3)^2 / 4; % cross sectional area of section 3 in m^2
    v_3 = v_2 * A_2 / A_3; % v in section 3
    
    Re_3 = (D(3) * v_3 * rho) / mu;
    f_3 = get_friction_factor(D(3), epsilon(3), Re_3);
    
    K_3 = 0;

    % K from diameter change
    if D(3) > D(2)
        K_3 = K_3 + (1 - (D(2) ^ 2 ) / (D(3) ^ 2)) ^ 2;
    else
        K_3 = K_3 + 0.5 * (1 - (D(2) ^ 2 ) / (D(3) ^ 2)) ^ 2;
    end

    deltaP_3 = ( (rho * v_3^2) / 2) * ( (f_3 * L(3) / D(3)) + K_3);

    %% Calculate total deltaP guess
    guess = deltaP_1 + deltaP_2 + deltaP_3;
end

function f = get_friction_factor(D, epsilon, Re)
    d = D * 1000; % convert diameter from m to mm

    % Laminar
    if Re < 2000
        f = 64 / Re;
        return
    end

    % Transitional – use laminar as fallback
    if Re < 3000
        f = 64 / Re;
        return
    end

    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);
end