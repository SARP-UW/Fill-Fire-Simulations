%% Calculates total Ethanol line pressure drop (psi)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   dP_sum_fu = get_ethanol_total_line_dP_psi(dP_Maj, dP_Min, dP_Cmp)
%
% Inputs:
%   dP_Maj - major line pressure drop (psi)
%   dP_Min - minor line pressure drop (psi)
%   dP_Cmp - component pressure drop (psi)
%
% Output:
%   dP_sum_fu - total pressure drop (psi)

function dP_sum_fu = get_ethanol_total_line_dP_psi(dP_Maj, dP_Min, dP_Cmp)
    dP_sum_fu = dP_Maj + dP_Min + dP_Cmp;
end
