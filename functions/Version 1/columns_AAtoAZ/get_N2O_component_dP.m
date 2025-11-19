%% Calculates Nitrous component line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_Cmp_Ox = get_N2O_component_dP(rho_Ox, Q_Ox, Cv_main)
%
% Inputs:
%   rho_Ox  - N2O density (kg/m^3)
%   Q_Ox    - N2O volumetric flow rate (GPM)
%   Cv_main - main valve flow coefficient (GPM/sqrt(psi))
%
% Output:
%   dP_Cmp_Ox - component line pressure drop (psi)

function dP_Cmp_Ox = get_N2O_component_dP(rho_Ox, Q_Ox, Cv_main)
    dP_Cmp_Ox = (rho_Ox / 1000) * (Q_Ox^2 / Cv_main^2);
end
