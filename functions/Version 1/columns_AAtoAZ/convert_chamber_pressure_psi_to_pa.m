%% Converts chamber pressure from psi to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   P_chamber_Pa = convert_chamber_pressure_psi_to_pa(P_chamber_psi)
%
% Input:
%   P_chamber_psi - chamber pressure (psi)
%
% Output:
%   P_chamber_Pa - chamber pressure (Pa)

function P_chamber_Pa = convert_chamber_pressure_psi_to_pa(P_chamber_psi)
    conversion_factor = 6894.76; % psi → Pa
    P_chamber_Pa = P_chamber_psi * conversion_factor;
end
