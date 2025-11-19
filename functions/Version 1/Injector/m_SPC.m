% function m_dot = m_SPC(Cd_i_SPC,A_inj_N2O,rho_inj_inlet, P_inj_inlet, P_chamber, T_inlet, gammaN2O)

    dP_across_inj = P_inj_inlet-P_chamber;
    %FML model paper https://www.mdpi.com/2226-4310/9/12/828#FD7-aerospace-09-00828
    %Rstar is specific gas constant for nitrous oxide. Rstar = Runiversal / Molar mass
    %Rstar = 8.314462618 / 0.044013 = 188.9092454
    Rstar = 188.9092454; %J / kg / K
    dZdTforcpressure = P_inj_inlet / Rstar * (dVdtforcpressure / T_inlet - 1 / (rho_inj_inlet*))
    
    %Z_compfac
    Z_compfac = P_inj_inlet / (rho_inj_inlet*R*T_inlet);

    %compressibiliy exponent n
    n = gammaN2O*(Z_compfac + T_inlet*dZdTforcrho) / (Z_compfac + T_inlet*dZdTforcpressure);

    %Y_compfac for compressible liq/real gases, eq 7
    Y_compfac = sqrt(  P_inj_inlet/(2*dP_across_inj)  *  (2*n/(n-1))  *  (1-dP_across_inj/P_inj_inlet)^(2/n)  *  (1-(1-dP_across_inj/P_inj_inlet)^((n-1)/n))  );

    %mdot_SPC, eq 5
    m_dot = Cd_i_SPC * Y_compfac * A_inj_N2O * sqrt(2 * rho_inj_inlet * (dP_across_inj));
    
% end

%Cp = dQ/dT at const P
%