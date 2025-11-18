function m_dot = m_SPC(Cd_i_SPC,A_inj_N2O,rho_inj_inlet)
    
    %FML model paper https://www.mdpi.com/2226-4310/9/12/828#FD7-aerospace-09-00828



    %mdot_SPC, eq 5
    m_dot = Cd_i_SPC * Y_compfac * A_inj_N2O * sqrt(2 * rho_inj_inlet * (dP_across_inj))
end