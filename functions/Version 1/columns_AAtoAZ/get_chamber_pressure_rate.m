%% Calculates rate of change of chamber pressure (dP/dt)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dPdt = get_chamber_pressure_rate(P_chamber_raw, P_chamber, dt)
%
% Inputs:
%   P_chamber_raw - raw chamber pressure (Pa)
%   P_chamber     - previous chamber pressure (Pa)
%   dt            - timestep (s)
%
% Output:
%   dPdt - rate of change of chamber pressure (Pa/s)

function dPdt = get_chamber_pressure_rate(P_chamber_raw, P_chamber, dt)
    dPdt = (P_chamber_raw - P_chamber) / dt;
end
