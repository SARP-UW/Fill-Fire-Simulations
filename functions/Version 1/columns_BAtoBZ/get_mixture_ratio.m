%% Calculates oxidizer-to-fuel mixture ratio (O/F)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   OF = get_mixture_ratio(mdot_Ox, mdot_fu)
%
% Inputs:
%   mdot_Ox - oxidizer mass flow (kg/s)
%   mdot_fu - fuel mass flow (kg/s)
%
% Outputs:
%   OF - mixture ratio (dimensionless)

function OF = get_mixture_ratio(mdot_Ox, mdot_fu)
    OF = mdot_Ox / mdot_fu;
end
