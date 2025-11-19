function mdot = mSPI(inj_Cd, inj_A, P_inj_inlet, P_chamber)
    
    rho_inlet = py.CoolProp.CoolProp.PropsSI('D', 'P', P_inj_inlet, 'Q', 0, 'NitrousOxide');

    mdot = inj_Cd * inj_A * sqrt( 2 * rho_inlet * (P_inj_inlet - P_chamber));

end
