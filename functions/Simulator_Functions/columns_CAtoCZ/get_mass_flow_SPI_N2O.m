%% Calculates N2O mass flow rate using the Single-Phase Incompressible (SPI) model
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   mdot_SPI = get_mass_flow_SPI_N2O(Cd_i, A_exit_i, rho_Ox, deltaP_i)
%
% Description:
%   Calculates the N2O mass flow assuming single-phase, incompressible flow.
%
% Inputs:
%   Cd_i     - discharge coefficient (dimensionless)
%   A_exit_i - injector exit area (m^2)
%   rho_Ox   - N2O density (kg/m^3)
%   deltaP_i - pressure drop across injector (Pa)
%
% Outputs:
%   mdot_SPI - N2O mass flow rate (kg/s)

function mdot_SPI = get_mass_flow_SPI_N2O(Cd_i, A_exit_i, rho_Ox, deltaP_i)
    mdot_SPI = Cd_i * A_exit_i * sqrt(2 * rho_Ox * deltaP_i);
end
