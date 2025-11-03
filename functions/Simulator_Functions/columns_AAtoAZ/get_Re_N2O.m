%% Calculates Nitrous Reynolds number
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Re_N2O = get_Re_N2O(mdot_N2O, D_i_N2O, eta_N2O)
%
% Inputs:
%   mdot_N2O - N2O mass flow (lbm/hr)
%   D_i_N2O  - inner diameter (in)
%   eta_N2O  - viscosity (centipoise)
%
% Output:
%   Re_N2O - Reynolds number (dimensionless)

function Re_N2O = get_Re_N2O(mdot_N2O, D_i_N2O, eta_N2O)
    Re_N2O = 6.315 * (mdot_N2O / (D_i_N2O * eta_N2O));
end
