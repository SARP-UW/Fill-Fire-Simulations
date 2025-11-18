%% Calculates nozzle pressure ratio (P/P0)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_ratio = get_pressure_ratio_P_over_P0(gamma_comb, M_exit)
%
% Inputs:
%   gamma_comb - combustion specific heat ratio (dimensionless)
%   M_exit     - exit Mach number (dimensionless)
%
% Output:
%   P_ratio - pressure ratio (P/P0, dimensionless)

function P_ratio = get_pressure_ratio_P_over_P0(gamma_comb, M_exit)
    P_ratio = (1 + (gamma_comb - 1) * M_exit^2) ^ (-gamma_comb / (gamma_comb - 1));
end
