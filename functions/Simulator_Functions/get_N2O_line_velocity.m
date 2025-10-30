%% Calculates N2O line velocity (m/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   v_Ox = get_N2O_line_velocity(mdot_Ox, rho_Ox, D_i_Ox)
%
% Inputs:
%   mdot_Ox - Nitrous mass flow (kg/s)
%   rho_Ox  - Nitrous density (kg/m^3)
%   D_i_Ox  - N2O line inner diameter (in)
%
% Output:
%   v_Ox - Flow velocity (m/s)

function v_Ox = get_N2O_line_velocity(mdot_Ox, rho_Ox, D_i_Ox)
    D_m = D_i_Ox * 0.0254;       % convert inches → meters
    A = pi * (D_m / 2)^2;        % cross-sectional area (m^2)
    v_Ox = mdot_Ox / (rho_Ox * A);
end
