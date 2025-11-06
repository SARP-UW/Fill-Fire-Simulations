%% Calculates Ethanol major line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Maj_fu = get_ethanol_major_dP(f_fu, L_line_fu, mdot_fu, rho_fu, D_i_fu)
%
% Inputs:
%   f_fu      - friction factor (dimensionless)
%   L_line_fu - line length (ft)
%   mdot_fu   - ethanol mass flow (lbm/hr)
%   rho_fu    - ethanol density (lbm/ft^3)
%   D_i_fu    - inner diameter (in)
%
% Output:
%   dP_Maj_fu - major pressure drop (psi)

function dP_Maj_fu = get_ethanol_major_dP(f_fu, L_line_fu, mdot_fu, rho_fu, D_i_fu)
    dP_Maj_fu = 3.35591e-6 * (f_fu * L_line_fu * mdot_fu^2) ...
               / (rho_fu * D_i_fu^5);
end
