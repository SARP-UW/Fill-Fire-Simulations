%% Calculates thrust rate (dF/dt) in N/s
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dFdt = get_thrust_rate(RThst, Thst, dt)
%
% Inputs:
%   RThst - raw thrust (N)
%   Thst  - current thrust (N)
%   dt    - timestep (s)
%
% Outputs:
%   dFdt - rate of thrust change (N/s)

function dFdt = get_thrust_rate(RThst, Thst, dt)
    dFdt = (RThst - Thst) / dt;
end
