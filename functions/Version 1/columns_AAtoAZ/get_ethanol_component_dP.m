%% Calculates Ethanol component pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Cmp_fu = get_ethanol_component_dP(S_fu, Q_fu, Cv_main)
%
% Inputs:
%   S_fu    - specific gravity (dimensionless)
%   Q_fu    - volumetric flow rate (GPM)
%   Cv_main - flow coefficient (GPM/sqrt(psi))
%
% Output:
%   dP_Cmp_fu - ethanol component pressure drop (psi)

function dP_Cmp_fu = get_ethanol_component_dP(S_fu, Q_fu, Cv_main)
    dP_Cmp_fu = (S_fu * Q_fu^2) / (Cv_main^2);
end
