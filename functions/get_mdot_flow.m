%% Calculates mdot from pressure difference across fill 
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39

function mdot_flow = get_mdot_flow(P1, P2, f, K_total, L, D, rho)
    % P1 = pressure in K bottle (Pa)
    % P2 = pressure in run tank (Pa)
    % f = friction factor (dimensionless)
    % K_total = total K-loss coefficients (dimensionless)
    % L = length of piping (m)
    % D = internal diameter of piping (m)
    % rho = density of nitrous (kg / m^3)
    % mdot_flow = mass flow of nitrous (kg / s)


    % Calculate area (m^2):
    A = pi * D^2 / 4;

    % Calculate mass flow:
    mdot_flow = rho * A * sqrt((2 * (P2 - P1)) / (rho * (f * (L / D) + K_total)));
end

