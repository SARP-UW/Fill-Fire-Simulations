function mdot_flow = get_mdot_flow(P1, P2, rho, mu, v_prev, t)
    %% Define characteristics from input sheet
    T = readtable();
    ; % K-bottle flow coefficient


    %% Calculate mdot
    deltaP = P1 - P2;

    if t ~= 0
        v_guess = 300; % initial velocity guess (m/s)
    else
        v_guess = v_prev; % get velocity from previous timestep
    end

    diff = @(v) deltaP - guess_deltaP();

    v_actual = fzero(diff, v_guess);

    mdot_flow = v_actual * rho * pi * D(1) ^ 2 / 4;

end

function guess = guess_deltaP(v_guess, rho, mu, D, L, epsilon)
    %% Section 1
    A_1 = pi * D(1)^2 / 4; % cross sectional area of section 1 in m^2
    v_1 = v_guess; % v in section 1

    Re_1 = (D(1) * v_1 * rho) / mu;
    f = get_friction_factor(D(1), epsilon(1), Re_1);

    K_1 = Cv * 0.865; % convert flow cofficient of k-bottle to metric
    
    deltaP_1 = ( (rho * v_1^2) / 2) * ( (f_1 * L(1) / D(1)) + K_1);
 
    %% Section 2
    A_2 = pi * D(2)^2 / 4; % cross sectional area of section 2 in m^2
    v_2 = v_1 * A_1 / A_2; % v in section 2
    Re_2 = (D(2) * v_2 * rho) / mu;
    f = get_friction_factor(D(2), epsilon(2), Re_2);

    K_2 = 0;
    % K from diameter change
    if D(2) > D(1)
        K = K + (1 - (D(1) ^ 2 ) / (D(2) ^ 2)) ^ 2;
    else
        K = K + 0.5 * (1 - (D(1) ^ 2 ) / (D(2) ^ 2)) ^ 2;
    end
    K_2 = K_2 + get_K_total(all_fittings, Re_2, D(2));

    deltaP_2 = ( (rho * v_2^2) / 2) * ( (f_2 * L(2) / D(2)) + K_2);


    %% Section 3
    A_3 = pi * D(3)^2 / 4; % cross sectional area of section 3 in m^2
    v_3 = v_2 * A_2 / A_3; % v in section 3
    
    Re_3 = (D(3) * v_3 * rho) / mu;
    f = get_friction_factor(D(3), epsilon(3), Re_3);
    
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

    % Calculate friction factor f with Serghide Approximation    
    A = -2 * log10((epsilon / (3.7 * d)) + (12 / Re));
    B = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * A) / Re));
    C = -2 * log10((epsilon / (3.7 * d)) + ((2.51 * B) / Re));
    f = (A - ((B-A)^2 / (C - (2 * B) + A)))^(-2);

end