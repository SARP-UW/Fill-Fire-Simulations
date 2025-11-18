%% Calculates Ethanol Reynolds number
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Re_fu = get_Re_ethanol(mdot_fu, D_i_fu, eta_fu)
%
% Inputs:
%   mdot_fu - ethanol mass flow (lbm/hr)
%   D_i_fu  - inner diameter (in)
%   eta_fu  - viscosity (centipoise)
%
% Output:
%   Re_fu - Reynolds number (dimensionless)

function Re_fu = get_Re_ethanol(mdot_fu, D_i_fu, eta_fu)
    Re_fu = 6.315 * (mdot_fu / (D_i_fu * eta_fu));
end
