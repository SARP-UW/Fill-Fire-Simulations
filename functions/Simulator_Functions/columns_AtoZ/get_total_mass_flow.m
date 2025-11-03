%% Calculates total mass flow (kg/s)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_total = get_total_mass_flow(mdot_Ox, mdot_Fu)
%
% Inputs:
%   mdot_Ox - N2O mass flow (kg/s)
%   mdot_Fu - ethanol mass flow (kg/s)
%
% Output:
%   mdot_total - total mass flow (kg/s)

function mdot_total = get_total_mass_flow(mdot_Ox, mdot_Fu)
    mdot_total = mdot_Ox + mdot_Fu;
end
