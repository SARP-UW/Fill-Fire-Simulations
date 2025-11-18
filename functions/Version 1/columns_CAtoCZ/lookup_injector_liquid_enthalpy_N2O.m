%% Looks up N2O injector outlet liquid enthalpy (J/kg)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   H_i_out_l_Ox = lookup_injector_liquid_enthalpy_N2O(ChPres)
%
% Description:
%   Retrieves the liquid enthalpy of N2O at injector outlet
%   based on chamber pressure from the N2O Liquid Phase Properties Table.
%
% Inputs:
%   ChPres - chamber pressure (psia)
%
% Outputs:
%   H_i_out_l_Ox - N2O injector outlet liquid enthalpy (J/kg)

function H_i_out_l_Ox = lookup_injector_liquid_enthalpy_N2O(ChPres)
    % TODO: replace with actual lookup function call
    H_i_out_l_Ox = lookup_property('N2O_Liquid', 'enthalpy', ChPres);
end
