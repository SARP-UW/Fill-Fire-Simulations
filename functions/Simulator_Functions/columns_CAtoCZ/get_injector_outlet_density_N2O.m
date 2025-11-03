%% Calculates N2O injector outlet density (kg/m^3)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   rho_i_out_Ox = get_injector_outlet_density_N2O(x_Ox, rho_g_Ox, rho_l_Ox)
%
% Description:
%   Calculates the density of N2O at the injector outlet using
%   a quality-weighted mixture of liquid and vapor densities.
%
% Inputs:
%   x_Ox     - N2O injector outlet quality (dimensionless)
%   rho_g_Ox - N2O injector outlet vapor density (kg/m^3)
%   rho_l_Ox - N2O injector outlet liquid density (kg/m^3)
%
% Outputs:
%   rho_i_out_Ox - N2O injector outlet density (kg/m^3)

function rho_i_out_Ox = get_injector_outlet_density_N2O(x_Ox, rho_g_Ox, rho_l_Ox)
    rho_i_out_Ox = (x_Ox .* rho_g_Ox) + (rho_l_Ox .* (1 - x_Ox));
end
