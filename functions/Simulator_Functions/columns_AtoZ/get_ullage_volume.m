%% Calculates ullage (nitrogen gas) volume (m^3)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   V_u = get_ullage_volume(V_u_prev, dt, rho_fu)
%
% Inputs:
%   V_u_prev - previous ullage volume (m^3)
%   dt       - timestep (s)
%   rho_fu   - ethanol density (kg/m^3)
%
% Output:
%   V_u - current ullage volume (m^3)

function V_u = get_ullage_volume(V_u_prev, dt, rho_fu)
    V_u = V_u_prev - (dt / rho_fu);
end
