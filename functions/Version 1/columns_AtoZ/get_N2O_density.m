%% Returns N2O density (kg/m^3) based on phase and tank pressure
% View full documentation here: https://www.overleaf.com/read/yzpnyzrksypj#0a7d39
%
% Syntax:
%   rho_Ox = get_N2O_density(phase, P_T_Ox)
%
% Inputs:
%   phase   - 'vapor' or 'liquid'
%   P_T_Ox  - N2O tank pressure (Pa)
%
% Output:
%   rho_Ox  - N2O density (kg/m^3)

function rho_Ox = get_N2O_density(phase, P_T_Ox)
    if strcmpi(phase, 'liquid')
        rho_table = readtable('N2O_Liquid_Phase_Properties.csv');
    elseif strcmpi(phase, 'vapor')
        rho_table = readtable('N2O_Vapor_Phase_Properties.csv');
    else
        error('Invalid phase: must be ''vapor'' or ''liquid''.');
    end

    pressures = rho_table.Pressure_Pa;
    densities = rho_table.Density_kg_m3;

    % Find closest pressure that is <= P_T_Ox
    idx = find(pressures <= P_T_Ox, 1, 'last');
    rho_Ox = densities(idx);
end
