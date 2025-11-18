%% Calculates raw thrust (N)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   RThst = get_raw_thrust(mdot_total, V_exit, ExhtPres, AmbiPres, A_exit)
%
% Inputs:
%   mdot_total - total mass flow rate (kg/s)
%   V_exit     - exit velocity (m/s)
%   ExhtPres   - exit pressure (Pa)
%   AmbiPres   - ambient pressure (Pa)
%   A_exit     - nozzle exit area (m^2)
%
% Outputs:
%   RThst - raw thrust (N)

function RThst = get_raw_thrust(mdot_total, V_exit, ExhtPres, AmbiPres, A_exit)
    RThst = (mdot_total * V_exit) + ((ExhtPres - AmbiPres) * A_exit);
end
