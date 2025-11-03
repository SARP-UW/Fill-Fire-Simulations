%% Calculates Ethanol injector pressure drop (Pa)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_i_fu = get_ethanol_injector_dP(P_inlet, P_chamber, dP_prev)
%
% Inputs:
%   P_inlet  - ethanol injector inlet pressure (Pa)
%   P_chamber - chamber pressure (Pa)
%   dP_prev   - previous injector pressure drop (Pa)
%
% Output:
%   dP_i_fu - ethanol injector pressure drop (Pa)

function dP_i_fu = get_ethanol_injector_dP(P_inlet, P_chamber, dP_prev)
    dP_i_fu = ((P_inlet - P_chamber) + dP_prev) / 2;
end
