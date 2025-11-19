%% Converts mass flow from kg/s to lbm/hr
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_lbmhr = convert_massflow_kgps_to_lbmhr(mdot_kgps)
%
% Input:
%   mdot_kgps - mass flow (kg/s)
%
% Output:
%   mdot_lbmhr - mass flow (lbm/hr)

function mdot_lbmhr = convert_massflow_kgps_to_lbmhr(mdot_kgps)
    conversion_factor = 7936.64; % 1 kg/s = 7936.64 lbm/hr
    mdot_lbmhr = mdot_kgps * conversion_factor;
end
