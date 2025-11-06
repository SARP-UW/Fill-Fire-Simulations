%% Converts total line pressure drop from psi to Pa
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   deltaP_Pa = convert_total_line_pressure_drop_pa(deltaP_psi)
%
% Input:
%   deltaP_psi - pressure drop (psi)
%
% Output:
%   deltaP_Pa - pressure drop (Pa)

function deltaP_Pa = convert_total_line_pressure_drop_pa(deltaP_psi)
    conversion_factor = 6894.76; % psi → Pa
    deltaP_Pa = deltaP_psi * conversion_factor;
end
