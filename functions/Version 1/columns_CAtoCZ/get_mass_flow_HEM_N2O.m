%% Calculates N2O mass flow rate using the Homogeneous Equilibrium Model (HEM)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_HEM = get_mass_flow_HEM_N2O(Cd_i, A_exit_i, rho_i_out, H_tank, H_i_out_g)
%
% Description:
%   Calculates the N2O mass flow rate using the HEM model, which assumes
%   liquid and vapor phases are homogeneously mixed and in thermal equilibrium.
%
% Inputs:
%   Cd_i     - discharge coefficient (dimensionless)
%   A_exit_i - injector exit area (m^2)
%   rho_i_out - N2O injector outlet density (kg/m^3)
%   H_tank   - N2O tank enthalpy (J/kg)
%   H_i_out_g - N2O injector outlet vapor enthalpy (J/kg)
%
% Outputs:
%   mdot_HEM - N2O mass flow rate via HEM model (kg/s)

function mdot_HEM = get_mass_flow_HEM_N2O(Cd_i, A_exit_i, rho_i_out, H_tank, H_i_out_g)
    mdot_HEM = Cd_i * A_exit_i * rho_i_out * sqrt(2 * (H_tank - H_i_out_g));
end
