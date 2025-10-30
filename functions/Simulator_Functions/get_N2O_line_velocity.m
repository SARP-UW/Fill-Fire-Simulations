%% Calculates N2O mass flow (kg/s) combining SPI and HEM branches
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_Ox = get_N2O_mass_flow(mdot_SPI, mdot_HEM, K)
%
% Description:
%   Computes the total nitrous oxide mass flow rate by weighting the
%   SPI and HEM mass flow contributions according to the exit loss
%   coefficient, K.
%
% Inputs:
%   mdot_SPI - N2O mass flow from the SPI line (kg/s)
%   mdot_HEM - N2O mass flow from the HEM line (kg/s)
%   K        - exit loss coefficient (dimensionless, typically 1)
%
% Output:
%   mdot_Ox  - combined N2O mass flow (kg/s)

function mdot_Ox = get_N2O_mass_flow(mdot_SPI, mdot_HEM, K)
    % If K not specified, assume typical value of 1
    if nargin < 3
        K = 1;
    end

    % Combine flows based on exit loss coefficient
    mdot_Ox = (1 - 1 / (1 + K)) * mdot_SPI + (1 / (1 + K)) * mdot_HEM;
end