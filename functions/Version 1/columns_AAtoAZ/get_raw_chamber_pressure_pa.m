%% Calculates raw chamber pressure (Pa)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_chamber_raw = get_raw_chamber_pressure_pa(c_star, mdot_total, A_throat)
%
% Inputs:
%   c_star     - characteristic velocity (m/s)
%   mdot_total - total mass flow (kg/s)
%   A_throat   - nozzle throat area (m^2)
%
% Output:
%   P_chamber_raw - raw chamber pressure (Pa)

function P_chamber_raw = get_raw_chamber_pressure_pa(c_star, mdot_total, A_throat)
    P_chamber_raw = (c_star * mdot_total) / A_throat;
end
