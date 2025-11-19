% transient sim --> pressure drop and thrust with time, using CEA data

clc;
clear;
close all;

% m_dot = 1.27; %total mass flow kg/s, temporary
A_t = 5.69 * (1/100)^2; %area of the throat, m^2
A_e = 123.899*(1/100)^2; %area of exit
A_ratio = A_e/A_t;
Ru = 8.314; % universal gas constant (J/K/mol)

%% nozzle geometry lol not important
%
% r_c = 0.0381; %chamber or converging radius
% r_t = 2.69/2*10^-2; %throat radius
% theta_c = 60; %converging angle
% theta_d = 15; %diverging angle
% Ae = 123.899*(1/100)^2; %area of exit
% r_e = sqrt(Ae/pi);
% 
% e = Ae/input.At;
% Ac = pi*r_c^2;
% l_c = tand(30)*(r_c-r_t);
% l_d = (r_e-r_t)/tand(15);
% l_ratio = l_c/l_d;
% nconv = round(l_ratio*nl);
% Aconv = linspace(Ac,input.At,nconv);
% Adiv = linspace(input.At,Ae,nl-nconv);
% Alist = [Aconv Adiv];
%
% figure
% plot(Alist.*(100^2))
% Ac/input.At;
% 1/Ae/input.At

%% CEA OUTPUT

% test
% filetext = fileread('test.txt');
% expr = 'P, BAR\d*';
% start = regexp(filetext,expr,"forcecelloutput");
% disp(start)
% f = 0;
% P = zeros(3,3); %% bar
% for i = 1:3 
%     P(i,1:3) = start{1,1}((i+f):(i*3))
%     f = f+2;
% end

% clc;
% clear;

keywords_input = ["Pin =", 'O/F='," # Pressure \("];
keywords_output = ["P, BAR", "T, K", "Cp, KJ/\(KG\)\(K\)", 'GAMMAs',"SON VEL,M/SEC","MACH NUMBER","CSTAR, M/SEC"];

filetext = fileread('CEAincompletesad.txt');

inputs = cell(length(keywords_input),1); 
for i = 1:length(keywords_input) 
    raw_lines = regexp(filetext,'(?<=' + keywords_input(i) + '\s*)\d+(\.\d+)?', 'match');
    vals = [];
    for j = 1:length(raw_lines)
        nums = str2double(regexp(raw_lines{j}, '\d+(\.\d+)?', 'match'));
        vals = [vals; nums];
    end
    inputs{i} = vals;
end


outputs = cell(length(keywords_output),1);
for i = 1:length(keywords_output) 
    raw_lines = regexp(filetext,'(?<=' + keywords_output(i) + ').*?(?=\r?\n|$)', 'match');
    vals = [];
    for j = 1:length(raw_lines)
        nums = str2double(regexp(raw_lines{j}, '\d+(\.\d+)?', 'match'));
        vals = [vals; nums];
    end
    outputs{i} = vals;
end

%% calcs
% outputs is in form outputs{Pressure, Temperature, Cp, Gamma, sonic velocity, Mach Number, Cstar)
% with the columns (chamber, throat, exit). C* has two columns but they are
% the same, cea outputs 2 for sum reason
% inputs is inputs{Input Pressure (into CEA), O/F ratio, nx (number of
% pressure variables)}

% unit conversion
bar2Pa = 100000;
nx = inputs{3}; % number of pressures per o/f ratio

gamma_e = reshape(outputs{4}(:,3),nx,[]);
Cp_e = reshape(outputs{3}(:,3)*10^3,nx,[]);
R_e = reshape(Cp_e.*(gamma_e-1)./gamma_e,nx,[]);
T_c = reshape(outputs{2}(:,1),nx,[]);
P_c = reshape(outputs{1}(:,1)*bar2Pa,nx,[]);
P_e = reshape(outputs{1}(:,3)*bar2Pa,nx,[]);
a_e = reshape(outputs{5}(:,3),nx,[]);
M_e = reshape(outputs{6}(:,3),nx,[]);
v_e = a_e.*M_e;
c_star = reshape(outputs{7}(:,1),nx,[]);
of = reshape(inputs{2},nx,[]);

P_0 = 101325;
m_dot = 1.27;
A_e = 123.899*(1/100)^2;


F = m_dot*v_e + (P_e - P_0)*A_e;
F_of = reshape(F,nx,[]); %% of1, of2, of3
P_in = reshape(inputs{1},nx,[]);

figure
plot(P_in, F_of)
legend('of = ' + string(inputs{2}(1)), 'of = ' + string(inputs{2}(1+nx)) ,...
    'of = ' + string(inputs{2}(1+2*nx)) )
ylabel('Thrust (N)')
xlabel('Chamber Pressure (psi)')

c_star_re = reshape(c_star,nx,[]);
figure
plot(P_in, c_star_re)
legend('of = ' + string(inputs{2}(1)), 'of = ' + string(inputs{2}(1+nx)) ,...
    'of = ' + string(inputs{2}(1+2*nx)) )
ylabel('cstar')
xlabel('Chamber Pressure (psi)')

%% given input, calculate output based on info
% c_star = PC At / Mdot 

ns = 10^3;
of_sim = linspace(4.1,4.1,ns); %temporary
m_dot = [linspace(0,1.5,.05*ns), linspace(1.5,1,0.95*ns)]; % temporary

% set up, ramp up cstar and calculate chambe pressure from it
c_star_sim_i = linspace(0,1400,0.01*ns);
c_star_sim = [c_star_sim_i, zeros(1,0.99*ns)];
P_c_sim_i = c_star_sim_i .* m_dot(1:0.01*ns) / A_t;
P_c_sim = [P_c_sim_i,  zeros(1,0.99*ns)];
P_c_index = zeros(1,ns);
of_index = zeros(1,ns);


% take imput of at a specific time, previous P_c step, and output C_star
% from model
for i = length(P_c_sim_i):ns
    of_index(i) = round( interp1( of(1,1:end), 1:numel(of(1,1:end)), round( of_sim(i), 1) ), 0 );
    if P_c_sim(i-1) < P_c(1)
        P_c_index(i) = 1;
    elseif P_c_sim(i-1) > P_c(end)
        P_c_index(i) = length(P_c);
    else
        P_c_index(i) = round( interp1( P_c(1:end,1).', 1:numel(P_c(1:end,1)), round( P_c_sim(i-1), 1) ) );
    end
    % P_c_sim(i-1)
    % P_c(P_c_index)
    c_star_sim(1,i) = c_star(P_c_index(i),of_index(i));
    P_c_sim(i) = c_star_sim(i) * m_dot(i) / A_t;
end

M_e_sim = zeros(1,ns);
a_e_sim = zeros(1,ns);
P_e_sim = zeros(1,ns);
for i = length(P_c_sim_i):ns
    M_e_sim(i) = M_e( P_c_index(i), of_index(i) );
    a_e_sim(i) = a_e( P_c_index(i), of_index(i) );
    P_e_sim(i) = P_e( P_c_index(i), of_index(i) );
end

v_e_sim = M_e_sim.*a_e_sim;
F_sim = m_dot.*v_e_sim + (P_e_sim - P_0)*A_e;

figure
plot(linspace(0,ns,ns),P_c_sim)
figure
plot(linspace(0,ns,ns),F_sim)
ylabel('thrust (N)')
