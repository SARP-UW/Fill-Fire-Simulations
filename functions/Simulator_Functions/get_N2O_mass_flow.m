%% Calculates N2O mass flow (kg/s) combining SPI and HEM branches
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_Ox = get_N2O_mass_flow(mdot_SPI, mdot_HEM, K)
%
% Inputs:
%   mdot_SPI - N2O mass flow from SPI (kg/s)
%   mdot_HEM - N2O mass flow from HEM (kg/s)
%   K        - exit loss coefficient (dimensionless, default = 1)
%
% Output:
%   mdot_Ox - combined N2O mass flow (kg/s)

function mdot_Ox = get_N2O_mass_flow(mdot_SPI, mdot_HEM, K)
    if nargin < 3, K = 1; end
    mdot_Ox = (1 - 1/(1 + K)) * mdot_SPI + (1/(1 + K)) * mdot_HEM;
end