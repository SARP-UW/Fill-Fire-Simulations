%% Calculates Ethanol friction factor (dimensionless)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   f_fu = get_friction_factor_ethanol(epsilon, D_i_fu, Re_fu)
%
% Inputs:
%   epsilon - surface roughness (in)
%   D_i_fu  - inner diameter (in)
%   Re_fu   - Reynolds number (dimensionless)
%
% Output:
%   f_fu - friction factor (dimensionless)

function f_fu = get_friction_factor_ethanol(epsilon, D_i_fu, Re_fu)
    f_fu = 0.25 / (log10((epsilon / (3.7 * D_i_fu)) + (5.74 / (Re_fu^0.9))))^2;
end
