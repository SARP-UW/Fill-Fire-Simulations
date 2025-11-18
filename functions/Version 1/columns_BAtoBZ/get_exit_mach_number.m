%% Calculates exit Mach number using linear interpolation
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   M_exit = get_exit_mach_number(M_120, M_125, gamma_comb)
%
% Inputs:
%   M_120      - Mach number at gamma = 1.20
%   M_125      - Mach number at gamma = 1.25
%   gamma_comb - combustion specific heat ratio (dimensionless)
%
% Outputs:
%   M_exit - exit Mach number (dimensionless)

function M_exit = get_exit_mach_number(M_120, M_125, gamma_comb)
    M_exit = M_120 + (gamma_comb - 1.20) * ((M_125 - M_120) / (1.25 - 1.20));
end
