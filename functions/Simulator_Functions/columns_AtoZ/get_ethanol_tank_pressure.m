%% Calculates Ethanol tank pressure (psia)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_T_fu = get_ethanol_tank_pressure(P_prev, V_u_prev, V_u)
%
% Inputs:
%   P_prev  - previous ethanol tank pressure (psia)
%   V_u_prev - ullage volume from previous timestep (m^3)
%   V_u      - current ullage volume (m^3)
%
% Output:
%   P_T_fu - ethanol tank pressure (psia)

function P_T_fu = get_ethanol_tank_pressure(P_prev, V_u_prev, V_u)
    P_T_fu = P_prev * (V_u_prev / V_u);
end
