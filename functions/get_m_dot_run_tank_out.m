function m_dot_run_tank_out = get_m_dot_run_tank_out(P_tank, P_atmosphere, t_nitrous, vapor_properties_table, orifice_diameter)
    %% This function calculates the mass flow out of the run tank for a given pressure

    % Determine nitrous properties
    [~, idx] = min(abs(vapor_properties_table.Temperature_K - t_nitrous));
    
    gamma = vapor_properties_table{idx, 9} / vapor_properties_table{idx, 8};
    rho = vapor_properties_table{idx, 3};

    P_tank = P_tank * 1e6; % Pa
    P_atmosphere = P_atmosphere * 6894.76; % psi to Pa

    % Determine orifice geometric properties
    orifice_diameter = orifice_diameter * 0.0254; % conv in to m
    beta = 0; % diameter ratio (setting to 0 for now, due to tank being much larger)
    Cd = 0.8; % discharge coefficient of orifice
    C = Cd / ((1 - (beta ^ 4)) ^ (1/2));
    A = pi * (orifice_diameter ^ 2) / 4;

    % Determine net expansion factor for compressible fluids
    Y = 1 - (0.351 + 0.256 * (beta^4) + 0.93 * (beta ^ 8)) * (1 - ( (P_atmosphere / P_tank) ^ (1/gamma)) );

    % Determine mass flow
    m_dot_run_tank_out = rho * Y * C * A * ((2 * (P_tank - P_atmosphere) / rho) ^ (1/2));

end