%% Calculates N2O injector pressure drop (Pa)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   deltaP_i_Ox = get_N2O_injector_dP(P_inlet, P_chamber)
%
% Inputs:
%   P_inlet   - N2O injector inlet pressure (Pa)
%   P_chamber - chamber pressure (Pa)
%
% Output:
%   deltaP_i_Ox - injector pressure drop (Pa)

function deltaP_i_Ox = get_N2O_injector_dP(P_inlet, P_chamber)
    deltaP_i_Ox = P_inlet - P_chamber;
end