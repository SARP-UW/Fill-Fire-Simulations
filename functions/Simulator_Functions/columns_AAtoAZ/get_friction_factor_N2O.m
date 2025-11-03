%% Calculates Nitrous friction factor (dimensionless)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   f_Ox = get_friction_factor_N2O(epsilon, D_i_Ox, Re_Ox)
%
% Inputs:
%   epsilon - surface roughness (in)
%   D_i_Ox  - inner diameter (in)
%   Re_Ox   - Reynolds number (dimensionless)
%
% Output:
%   f_Ox - friction factor (dimensionless)

function f_Ox = get_friction_factor_N2O(epsilon, D_i_Ox, Re_Ox)
    f_Ox = 0.25 / (log10((epsilon / (3.7 * D_i_Ox)) + (5.74 / (Re_Ox^0.9))))^2;
end
