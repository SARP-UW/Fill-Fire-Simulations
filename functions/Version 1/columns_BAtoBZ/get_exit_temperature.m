%% Calculates exit gas temperature (K)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   ExhtTmp = get_exit_temperature(ChTmp, gamma_cmb, M_exit)
%
% Inputs:
%   ChTmp     - chamber temperature (K)
%   gamma_cmb - combustion specific heat ratio (dimensionless)
%   M_exit    - exit Mach number (dimensionless)
%
% Outputs:
%   ExhtTmp - exit gas temperature (K)

function ExhtTmp = get_exit_temperature(ChTmp, gamma_cmb, M_exit)
    ExhtTmp = ChTmp / (1 + ((gamma_cmb - 1) / (2 * M_exit^2)));
end
