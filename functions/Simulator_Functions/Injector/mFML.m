function m_FML = mFML(qualOut, denOutLiq, denOutVap, pOut, pIn, Cd, denInLiq, gamma, a_orifice, enthIn, enthOut, phase, molarMass, tempIn, volIn, denOut)
    % This function calculates the injector mass flow using the FML model.

    % qualIn - quality inlet
    % qualOut - quality outlet
    % denOutLiq - outlet liquid density
    % denOutVap - outlet vapor density
    % pOut - outlet pressure
    % pIn - inlet pressure
    % Cd - discharge coefficient
    % denInLiq - inlet liquid density
    % gamma - specific heat ratios
    % a_orifice - area of orifice
    % enthIn - inlet enthalpy
    % enthOut - outlet enthalpy
    % phase - phase of nitrous in tank
    % molarMass - molar mass
    % tempIn - inlet temperature   
    % volIn - inlet volume
    % prevVolIn - previous timestep inlet volume
    % prevTempIn - previous timestep inlet temperature
    
    R = 10.731; % universal gas constant, (psi⋅ft3/lbmol⋅°R)
    R_star = R / molarMass; % specific universal gas constant (psi⋅ft3/lb⋅°R)
    dP = pIn - pOut; % dP across injector
    delZT_rho = (pIn/R_star) * ((1/tempIn)* (dv/dT)... % use lookup table here
        -volIn/(tempIn^2)); % derivative approximation for the isentropic power law exponent
    delZT_p = 1/(denInLiq*R_star) * (1/tempIn * (dP/dT) ... % use lookup table here
        - pIn/(tempIn^2)); % derivative approximation for the isentropic power law exponent
    Z = pIn * vIn / (R * tempIn); % Compressiblity factor
    n = gamma * ((Z + T * delZT_rho)/(Z + T * delZT_p)); % isentropic power law exponent
    slipVelocity = (denOutLiq/denOutVap)^(1/3); % phase slip velocity
    voidFraction = 1 / (1 + (1-qualOut)/qualOut*slipVelocity*(denOutVap/denOutLiq)); % downstream void fraction
    % Y = sqrt(((pOut/pIn)^(2/gamma)) * (gamma/(gamma-1)) * (1-((pOut/pIn)^((gamma-1)/gamma))) / (1-(pOut/pIn))); % for an ideal gas and small pipe-diameter ratios compressibility correction factor
    Y = sqrt(pIn/(2 * dP) * 2*n/(n-1) * (1 - dP/pIn)^(2/n) * (1 - (1 - dP/pIn)^((n-1)/n))); 
    m_SPC = Cd * Y * a_orifice * sqrt(2 * denInLiq * (pIn - pOut)); % mass flow from SPC
    m_HEM = Cd * a_orifice * denOut * sqrt(2*(enthIn - enthOut)); % mass flow from HEM
    % Figure out what the c subscript means, probably means critical flow. Understand why this is. 
    if phase == "liquid"
        m_FML = (1 - voidFraction) * m_SPC + voidFraction * m_HEM; % mass flow from FML
    else
        m_FML = voidFraction * m_SPC + (1 - voidFraction) * m_HEM; % mass flow from FML
    end
end