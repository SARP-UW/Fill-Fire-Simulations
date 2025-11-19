function mdot = m_FML(mSPC, mHEMc, chamber_pressure, P_inj_inlet, phase)
    rho_downstream_l = py.CoolProp.CoolProp.PropsSI('D', 'P', chamber_pressure, 'Q', '0', "NitrousOxide");
    rho_downstream_v = py.CoolProp.CoolProp.PropsSI('D', 'P', chamber_pressure, 'Q', '1', "NitrousOxide");

    slip_velocity = (rho_downstream_l/rho_downstream_v)^(1/3);
    entropy_inlet = py.CoolProp.CoolProp.PropsSI('S', 'P', P_inj_inlet, 'Q', 0, 'NitrousOxide');
    entropy_outlet_l = py.CoolProp.CoolProp.PropsSI('S', 'P', chamber_pressure, 'Q', 0, 'NitrousOxide');
    entropy_outlet_v = py.CoolProp.CoolProp.PropsSI('S', 'P', chamber_pressure, 'Q', 1, 'NitrousOxide');
    
    % Quality Calculation
    % s_tank = s_inj_outlet (assumption of isentropic flow)
    % s_inj_outlet = s_inj_out_liq*(1-x) + s_inj_out_vap*x
    % s_inj_outlet = s_inj_out_liq + (s_inj_out_vap-s_inj_out_liq)*x
    % (s_inj_outlet - s_inj_out_liq) / (s_inj_out_vap-s_inj_out_liq) = 
    x_inj_out = (entropy_inlet - entropy_outlet_l) / (entropy_outlet_v-entropy_outlet_l);

    void_fraction = 1/(1+(1-x_inj_out) / x_inj_out * slip_velocity * (rho_downstream_v / rho_downstream_l));

    if phase == "liquid"
        mdot = (1 - void_fraction) * mSPC + void_fraction * mHEMc;
    else
        mdot = void_fraction * mSPC + (1 - void_fraction) * mHEMc;
    end
end