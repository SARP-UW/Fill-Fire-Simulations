%% Calculates Ethanol flow velocity (m/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   v_fu = get_ethanol_velocity(mdot_fu, rho_fu0, D_i_fu)
%
% Inputs:
%   mdot_fu - Ethanol mass flow (kg/s)
%   rho_fu0 - Initial ethanol density (kg/m^3)
%   D_i_fu  - Ethanol tube inner diameter (in)
%
% Output:
%   v_fu - Ethanol line velocity (m/s)

function v_fu = get_ethanol_velocity(mdot_fu, rho_fu0, D_i_fu)
    D_m = D_i_fu * 0.0254;     % convert inches → meters
    A = pi * (D_m / 2)^2;      % area (m^2)
    v_fu = mdot_fu / (rho_fu0 * A);
end
