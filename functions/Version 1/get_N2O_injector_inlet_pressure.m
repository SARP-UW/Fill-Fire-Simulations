%% Calculates N2O injector inlet pressure (psia)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% For use in Sim Version 1, do not use in Version 0 
%
% Syntax:
%   P_i_Ox = get_N2O_injector_inlet_pressure(P_T_Ox, dP_sum_Ox)
%
% Inputs:
%   P_T_Ox   - tank pressure (psia)
%   dP_sum_Ox - total line pressure drop (psi)
%
% Constant:
%   adj_factor - adjustment factor (psi), see sim architecture doc
%
% Output:
%   P_i_Ox - injector inlet pressure (psia)

function P_i_Ox = get_N2O_injector_inlet_pressure(P_T_Ox, dP_sum_Ox)
    adj_factor = 20;
    P_i_Ox = P_T_Ox - dP_sum_Ox + adj_factor;
end
