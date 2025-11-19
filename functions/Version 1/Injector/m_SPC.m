function m_dot = m_SPC(Cd_i_SPC,A_inj_N2O,P_inj_inlet, P_chamber)
    % Cd_i_SPC = 0.9;
    % A_inj_N2O = 0.0001535;
    % P_inj_inlet = 5e6;
    % P_chamber = 4.137e6;
    cp = py.CoolProp.CoolProp.PropsSI("CPMASS", "P", P_inj_inlet, "Q", 0, "NitrousOxide");
    cv = py.CoolProp.CoolProp.PropsSI("CVMASS", "P", P_inj_inlet, "Q", 0, "NitrousOxide");
    %entropy = py.CoolProp.CoolProp.PropsSI("S", "P", P_inj_inlet, "Q", 0, "NitrousOxide");
    gammaN2O = cp/cv;
   

    dP_across_inj = P_inj_inlet-P_chamber;
    %FML model paper https://www.mdpi.com/2226-4310/9/12/828#FD7-aerospace-09-00828
    %Rstar is specific gas constant for nitrous oxide. Rstar = Runiversal / Molar mass
    %Rstar = 8.314462618 / 0.044013 = 188.9092454
    % R = 8.314462618;
    % Rstar = 188.9092454; %J / kg / K
    T_inlet = py.CoolProp.CoolProp.PropsSI('T', 'P', P_inj_inlet, 'Q', 0, "NitrousOxide");
    rho_inj_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', 0, "NitrousOxide");
    %dZdTforcpressure = P_inj_inlet / Rstar * (dVdtforcpressure / T_inlet - 1 / (rho_inj_inlet*))
    %dVdTforcpressure = py.CoolProp.CoolProp.PropsSI('d(V)/d(T)|P', "P|liquid", P_inj_inlet, "Q", 0.0001, "NitrousOxide");
    h = 2;
    dZdTforcrho = (py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet, 'D', rho_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-h, 'D', rho_inj_inlet, 'NitrousOxide'))/h;
    dZdTforcpressure = (py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-h/2, 'P', P_inj_inlet, 'NitrousOxide') - py.CoolProp.CoolProp.PropsSI('Z', 'T', T_inlet-3*h/2, 'P', P_inj_inlet, 'NitrousOxide'))/h;
    
    Z_compfac = py.CoolProp.CoolProp.PropsSI('Z', 'P', P_inj_inlet, 'D', rho_inj_inlet, "NitrousOxide");

    %Z_compfac

    % Z_compfac = P_inj_inlet / (rho_inj_inlet*R*T_inlet);

    %compressibiliy exponent n
    n = gammaN2O*(Z_compfac + T_inlet*dZdTforcrho) / (Z_compfac + T_inlet*dZdTforcpressure);

    %Y_compfac for compressible liq/real gases, eq 7
    Y_compfac = sqrt(  P_inj_inlet/(2*dP_across_inj)  *  (2*n/(n-1))  *  (1-dP_across_inj/P_inj_inlet)^(2/n)  *  (1-(1-dP_across_inj/P_inj_inlet)^((n-1)/n))  );

    %mdot_SPC, eq 5
    m_dot = Cd_i_SPC * Y_compfac * A_inj_N2O * sqrt(2 * rho_inj_inlet * (dP_across_inj));
    
end