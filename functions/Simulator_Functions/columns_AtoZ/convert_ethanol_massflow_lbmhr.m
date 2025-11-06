%% Converts Ethanol mass flow (kg/s) to (lbm/hr)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_lbmhr = convert_ethanol_massflow_lbmhr(mdot_kgps)
%
% Input:
%   mdot_kgps - Ethanol mass flow (kg/s)
%
% Output:
%   mdot_lbmhr - Ethanol mass flow (lbm/hr)

function mdot_lbmhr = convert_ethanol_massflow_lbmhr(mdot_kgps)
    conversion_factor = 7936.64;
    mdot_lbmhr = mdot_kgps * conversion_factor;
end
