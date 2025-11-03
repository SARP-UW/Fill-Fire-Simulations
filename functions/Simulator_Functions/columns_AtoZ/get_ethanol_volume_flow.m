%% Calculates Ethanol volume flow rate (GPM)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Q_fu = get_ethanol_volume_flow(mdot_fu, rho_fu0)
%
% Inputs:
%   mdot_fu - Ethanol mass flow (kg/s)
%   rho_fu0 - Initial ethanol density (kg/m^3)
%
% Output:
%   Q_fu - Ethanol volumetric flow rate (GPM)

function Q_fu = get_ethanol_volume_flow(mdot_fu, rho_fu0)
    conversion_factor = 15850.323;
    Q_fu = (mdot_fu / rho_fu0) * conversion_factor;
end
