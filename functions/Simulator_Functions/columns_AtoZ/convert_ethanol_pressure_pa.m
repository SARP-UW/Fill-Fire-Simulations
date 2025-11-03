%% Converts Ethanol tank pressure from psia to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_Pa = convert_ethanol_pressure_pa(P_psia)
%
% Input:
%   P_psia - ethanol tank pressure (psia)
%
% Output:
%   P_Pa - ethanol tank pressure (Pa)

function P_Pa = convert_ethanol_pressure_pa(P_psia)
    conversion_factor = 6894.75729;
    P_Pa = P_psia * conversion_factor;
end
