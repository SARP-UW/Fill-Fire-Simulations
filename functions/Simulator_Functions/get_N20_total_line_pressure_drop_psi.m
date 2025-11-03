%% Calculates total N2O line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   deltaP_sum = get_total_line_pressure_drop_psi(deltaP_maj, deltaP_min, deltaP_cmp)
%
% Inputs:
%   deltaP_maj - major pressure drop (psi)
%   deltaP_min - minor pressure drop (psi)
%   deltaP_cmp - component pressure drop (psi)
%
% Output:
%   deltaP_sum - total pressure drop (psi)

function deltaP_sum = get_total_line_pressure_drop_psi(deltaP_maj, deltaP_min, deltaP_cmp)
    deltaP_sum = (deltaP_maj + deltaP_min + deltaP_cmp) * 0.6;
end
