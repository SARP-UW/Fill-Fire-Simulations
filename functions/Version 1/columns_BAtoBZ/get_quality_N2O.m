%% Calculates N2O injector outlet quality (x)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   x_Ox = get_quality_N2O(S_Ox, S_i_Out_l, S_i_Out_g)
%
% Inputs:
%   S_Ox      - tank entropy (J/g/K)
%   S_i_Out_l - injector outlet liquid entropy (J/g/K)
%   S_i_Out_g - injector outlet vapor entropy (J/g/K)
%
% Outputs:
%   x_Ox - N2O outlet quality (dimensionless)

function x_Ox = get_quality_N2O(S_Ox, S_i_Out_l, S_i_Out_g)
    x_Ox = (S_Ox - S_i_Out_l) / (S_i_Out_g - S_i_Out_l);
end
