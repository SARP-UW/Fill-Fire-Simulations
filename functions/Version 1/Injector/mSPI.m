function mdot = mSPI(inj_Cd, inj_A, P_inj_inlet, P_chamber, phase, fluid)
    
    Q = 0;
    if phase == "vapor"
        Q = 1;
    end
    if fluid == 'ethanol'
        rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, 'Ethanol');
    else
        rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, 'NitrousOxide');
    end
    
    mdot = inj_Cd * inj_A * sqrt( 2 * rho_inlet * (P_inj_inlet - P_chamber));

end
