%% Calculates exit pressure (Pa)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   ExhtPres = get_exit_pressure(ChPres, P_ratio)
%
% Inputs:
%   ChPres  - chamber pressure (Pa)
%   P_ratio - pressure ratio (P/P0)
%
% Outputs:
%   ExhtPres - exit pressure (Pa)

function ExhtPres = get_exit_pressure(ChPres, P_ratio)
    ExhtPres = ChPres * P_ratio;
end
