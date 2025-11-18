%% Calculates N2O volume flow (GPM)
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   Q_Ox = get_N2O_volume_flow(mdot_Ox, rho_Ox)
%
% Inputs:
%   mdot_Ox - N2O mass flow (kg/s)
%   rho_Ox  - N2O density (kg/m^3)
%
% Output:
%   Q_Ox - N2O volumetric flow rate (GPM)

function Q_Ox = get_N2O_volume_flow(mdot_Ox, rho_Ox)
    conversion_factor = 15850.323; % m^3/s → GPM
    Q_Ox = (mdot_Ox / rho_Ox) * conversion_factor;
end
