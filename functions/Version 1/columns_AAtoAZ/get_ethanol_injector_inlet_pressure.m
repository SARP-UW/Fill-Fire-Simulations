%% Calculates Ethanol injector inlet pressure (psia)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_i_fu = get_ethanol_injector_inlet_pressure(P_T_fu, dP_sum_fu)
%
% Inputs:
%   P_T_fu   - ethanol tank pressure (psia)
%   dP_sum_fu - total ethanol pressure drop (psi)
%
% Output:
%   P_i_fu - ethanol injector inlet pressure (psia)

function P_i_fu = get_ethanol_injector_inlet_pressure(P_T_fu, dP_sum_fu)
    P_i_fu = P_T_fu - dP_sum_fu;
end
