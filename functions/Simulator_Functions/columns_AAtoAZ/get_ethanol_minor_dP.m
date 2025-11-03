%% Calculates Ethanol minor line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Min_fu = get_ethanol_minor_dP(K_sum_fu, mdot_fu, rho_fu, D_i_fu)
%
% Inputs:
%   K_sum_fu - total K values for fittings/bends/etc.
%   mdot_fu  - ethanol mass flow (lbm/hr)
%   rho_fu   - ethanol density (lbm/ft^3)
%   D_i_fu   - ethanol inner diameter (in)
%
% Output:
%   dP_Min_fu - minor pressure drop (psi)

function dP_Min_fu = get_ethanol_minor_dP(K_sum_fu, mdot_fu, rho_fu, D_i_fu)
    dP_Min_fu = 2.799e-7 * (K_sum_fu * mdot_fu^2) / (rho_fu * D_i_fu^4);
end
