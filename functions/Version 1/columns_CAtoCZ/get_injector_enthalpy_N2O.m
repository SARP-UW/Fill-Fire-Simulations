%% Calculates N2O injector outlet enthalpy (J/kg)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   H_i_out_N2O = get_injector_enthalpy_N2O(x_Ox, H_g_N2O, H_l_N2O)
%
% Description:
%   Calculates the mixed-phase enthalpy of N2O at injector outlet
%   using a quality-weighted combination of vapor and liquid enthalpies.
%
% Inputs:
%   x_Ox    - N2O outlet quality (dimensionless)
%   H_g_N2O - N2O vapor enthalpy (J/kg)
%   H_l_N2O - N2O liquid enthalpy (J/kg)
%
% Outputs:
%   H_i_out_N2O - N2O injector outlet enthalpy (J/kg)

function H_i_out_N2O = get_injector_enthalpy_N2O(x_Ox, H_g_N2O, H_l_N2O)
    H_i_out_N2O = x_Ox .* H_g_N2O + (1 - x_Ox) .* H_l_N2O;
end
