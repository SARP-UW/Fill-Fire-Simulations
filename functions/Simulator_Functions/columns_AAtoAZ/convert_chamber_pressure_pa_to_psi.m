%% Converts chamber pressure from Pa to psi
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_chamber_psi = convert_chamber_pressure_pa_to_psi(P_chamber_Pa)
%
% Input:
%   P_chamber_Pa - chamber pressure (Pa)
%
% Output:
%   P_chamber_psi - chamber pressure (psi)

function P_chamber_psi = convert_chamber_pressure_pa_to_psi(P_chamber_Pa)
    conversion_factor = 1 / 6894.76; % Pa → psi
    P_chamber_psi = P_chamber_Pa * conversion_factor;
end
