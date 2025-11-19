%% Calculates Nitrous major line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Maj_Ox = get_N2O_major_dP(f_Ox, L_line_Ox, mdot_Ox, rho_Ox, D_i_Ox)
%
% Inputs:
%   f_Ox       - friction factor (dimensionless)
%   L_line_Ox  - line length including fittings (ft)
%   mdot_Ox    - N2O mass flow (lbm/hr)
%   rho_Ox     - N2O density (kg/m^3)
%   D_i_Ox     - inner diameter (in)
%
% Output:
%   dP_Maj_Ox - major pressure drop (psi)

function dP_Maj_Ox = get_N2O_major_dP(f_Ox, L_line_Ox, mdot_Ox, rho_Ox, D_i_Ox)
    dP_Maj_Ox = 3.3591e-6 * (f_Ox * L_line_Ox * mdot_Ox^2) ...
               / (0.062428 * rho_Ox * D_i_Ox^5);
end
