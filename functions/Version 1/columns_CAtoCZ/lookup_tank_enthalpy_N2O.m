%% Looks up N2O tank enthalpy (J/kg)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   H_tank_Ox = lookup_tank_enthalpy_N2O(P_T_Ox)
%
% Description:
%   Retrieves the tank enthalpy of liquid N2O from the
%   N2O Liquid Phase Properties Table based on tank pressure.
%
% Inputs:
%   P_T_Ox - N2O tank pressure (psia)
%
% Outputs:
%   H_tank_Ox - N2O tank enthalpy (J/kg)

function H_tank_Ox = lookup_tank_enthalpy_N2O(P_T_Ox)
    % TODO: replace with actual table lookup from N2O Liquid Phase Properties
    H_tank_Ox = lookup_property('N2O_Liquid', 'enthalpy', P_T_Ox);
end
