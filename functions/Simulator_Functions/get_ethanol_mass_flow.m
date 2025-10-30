%% Calculates Ethanol mass flow rate (kg/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_fu = get_ethanol_mass_flow(Cd_fu, A_exit_fu, rho_fu0, deltaP_fu)
%
% Inputs:
%   Cd_fu     - discharge coefficient (dimensionless)
%   A_exit_fu - injector exit area (m^2)
%   rho_fu0   - initial ethanol density (kg/m^3)
%   deltaP_fu - ethanol pressure drop (Pa)
%
% Output:
%   mdot_fu   - ethanol mass flow (kg/s)

function mdot_fu = get_ethanol_mass_flow(Cd_fu, A_exit_fu, rho_fu0, deltaP_fu)
    mdot_fu = Cd_fu * A_exit_fu * sqrt(2 * rho_fu0 * deltaP_fu);
end