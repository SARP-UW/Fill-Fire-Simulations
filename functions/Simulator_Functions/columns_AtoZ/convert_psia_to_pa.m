%% Converts pressure from psia to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_Pa = convert_psia_to_pa(P_psia)
%
% Input:
%   P_psia - pressure in psia
%
% Output:
%   P_Pa - pressure in Pa

function P_Pa = convert_psia_to_pa(P_psia)
    conversion_factor = 6894.75729; % 1 psia = 6894.75729 Pa
    P_Pa = P_psia * conversion_factor;
end
