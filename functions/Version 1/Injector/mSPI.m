function mdot = mSPI(inj_Cd, inj_A, P_inj_inlet, P_chamber, phase)
    
    Q = 0;
    if phase == "vapor"
        Q = 1;
    end
    rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', Q, 'NitrousOxide');

    mdot = inj_Cd * inj_A * sqrt( 2 * rho_inlet * (P_inj_inlet - P_chamber));

end
