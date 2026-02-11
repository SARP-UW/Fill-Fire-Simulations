function m_dot_run_tank_out = get_m_dot_run_tank_out(P_tank, P_atmosphere, t_nitrous, orifice_diameter)
    %% This function calculates the mass flow out of the run tank for a given pressure

    % Determine nitrous properties
    %[~, idx] = min(abs(vapor_properties_table.Temperature_K - t_nitrous));
    
    %gamma = vapor_properties_table{idx, 9} / vapor_properties_table{idx, 8};
    %rho = vapor_properties_table{idx, 3};

    % Determine nitrous properties(new)
    cp = py.CoolProp.CoolProp.PropsSI('Cpmass', 'T', t_nitrous, 'Q', 1, 'N2O');
    cv = py.CoolProp.CoolProp.PropsSI('Cvmass', 'T', t_nitrous, 'Q', 1, 'N2O');
    gamma = cp / cv; % Calculate specific heat ratio
    P_tank = P_tank * 10^6; % Pa
    P_atmosphere = P_atmosphere * 6894.76; % psi to Pa
    R = 188.91; % specific gas constant of nitrogen

    % Determine orifice geometric properties
    orifice_diameter = orifice_diameter * 0.0254; % conv in to m
    Cd = 0.8; % discharge coefficient of orifice
    A = pi * (orifice_diameter ^ 2) / 4;

    % Check if flow is choked
    p_ratio = P_atmosphere / P_tank;
    p_ratio_crit = (2 / (gamma + 1))^(gamma / (gamma -1));
    if p_ratio <= p_ratio_crit % choked flow
        m_dot_run_tank_out = Cd * A * P_tank * sqrt(gamma / (R * t_nitrous)) * (2 / (gamma + 1))^((gamma + 1)/(2 * (gamma - 1)));
    else % unchoked
        x = p_ratio^(2/gamma) - p_ratio^((gamma + 1)/gamma);
        y = (2 * gamma) / (R * t_nitrous * (gamma - 1)) * x;
        m_dot_run_tank_out = Cd * A * P_tank * sqrt(y);
    end
end