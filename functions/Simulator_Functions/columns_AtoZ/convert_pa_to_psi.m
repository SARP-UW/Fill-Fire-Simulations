%% Converts pressure from Pa to psi
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_psi = convert_pa_to_psi(P_Pa)
%
% Input:
%   P_Pa - pressure in pascals (Pa)
%
% Output:
%   P_psi - pressure in psi

function P_psi = convert_pa_to_psi(P_Pa)
    conversion_factor = 1 / 6894.76;
    P_psi = P_Pa * conversion_factor;
end
