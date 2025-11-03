%% Calculates Nitrous minor line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Min_Ox = get_N2O_minor_dP(K_sum_Ox, mdot_Ox, rho_Ox, D_i_Ox)
%
% Inputs:
%   K_sum_Ox  - total K values (dimensionless)
%   mdot_Ox   - N2O mass flow (lbm/hr)
%   rho_Ox    - N2O density (kg/m^3)
%   D_i_Ox    - N2O inner diameter (in)
%
% Output:
%   dP_Min_Ox - minor pressure drop (psi)

function dP_Min_Ox = get_N2O_minor_dP(K_sum_Ox, mdot_Ox, rho_Ox, D_i_Ox)
    dP_Min_Ox = 2.799e-7 * (K_sum_Ox * mdot_Ox^2) ...
               / (0.062428 * rho_Ox * D_i_Ox^4);
end
