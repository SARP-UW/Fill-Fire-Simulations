%% Looks up N2O injector outlet vapor enthalpy (J/kg)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   H_i_out_g_Ox = lookup_injector_vapor_enthalpy_N2O(ChPres)
%
% Description:
%   Retrieves the vapor enthalpy of N2O at the injector outlet
%   from the N2O Vapor Phase Properties Table using chamber pressure.
%
% Inputs:
%   ChPres - chamber pressure (psia)
%
% Outputs:
%   H_i_out_g_Ox - N2O injector outlet vapor enthalpy (J/kg)

function H_i_out_g_Ox = lookup_injector_vapor_enthalpy_N2O(ChPres)
    % TODO: replace with actual lookup function call
    H_i_out_g_Ox = lookup_property('N2O_Vapor', 'enthalpy', ChPres);
end
