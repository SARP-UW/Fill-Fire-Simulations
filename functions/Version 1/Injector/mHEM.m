function mdot = mHEM(inj_Cd, inj_A, P_inj_inlet, P_chamber, phase)

    x = 0;
    if phase == "vapor"
        x = 1;
    end
    
    if P_chamber == 0
        mdot = 0.1;
        return;
    end

    s_in = py.CoolProp.CoolProp.PropsSI('S', 'P', P_inj_inlet, 'Q', x, "NitrousOxide"); %J/(kg*K)
    rho_outlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_chamber, 'S', s_in, 'NitrousOxide');
    enth_in = py.CoolProp.CoolProp.PropsSI('H', 'P', P_inj_inlet, 'Q', x, 'NitrousOxide');
    enth_out = py.CoolProp.CoolProp.PropsSI('H', 'P', P_chamber, 'S', s_in, 'NitrousOxide');

    mdot = inj_Cd * inj_A * rho_outlet * sqrt( 2 * (enth_in - enth_out) );
end