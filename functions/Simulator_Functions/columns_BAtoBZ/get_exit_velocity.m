%% Calculates exit velocity (m/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   V_exit = get_exit_velocity(M_exit, gamma_cmb, R_cmb, ExhtTmp)
%
% Inputs:
%   M_exit   - exit Mach number (dimensionless)
%   gamma_cmb - combustion specific heat ratio (dimensionless)
%   R_cmb    - combustion specific gas constant (J/kg/K)
%   ExhtTmp  - exit gas temperature (K)
%
% Outputs:
%   V_exit - exit gas velocity (m/s)

function V_exit = get_exit_velocity(M_exit, gamma_cmb, R_cmb, ExhtTmp)
    V_exit = M_exit * sqrt(gamma_cmb * R_cmb * ExhtTmp);
end
