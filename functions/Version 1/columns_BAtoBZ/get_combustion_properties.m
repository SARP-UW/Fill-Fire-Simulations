%% Retrieves combustion properties constants
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   [gamma_cmb, M_cmb, R_cmb] = get_combustion_properties()
%
% Inputs:
%   None
%
% Outputs:
%   gamma_cmb - specific heat ratio
%   M_cmb     - molecular weight (g/mol)
%   R_cmb     - specific gas constant (J/kg/K)

function [gamma_cmb, M_cmb, R_cmb] = get_combustion_properties()
    gamma_cmb = 1.229;
    M_cmb = 29.55522;
    R_cmb = 281.3039456;
end
