function [M, C, D, tau_liftdrag, tau_crossflow, J, g] = payload(nu, nu_r, x)
% function for the payload module calculating the 
% Called in main_modular.m

S = load("PayloadParameters.mat");
payload = S.payload;

% declaration of the sizes of the variables for C compilation in SIMULINK
M = zeros(6,6);C = zeros(6,6); D = zeros(6,6); 
J = zeros(6,6);g = zeros(6,1);tau_liftdrag = zeros (6,1);
tau_crossflow = zeros (6,1);

U_r = sqrt( nu_r(1)^2 + nu_r(2)^2 + nu_r(3)^2 );  % relative speed (m/s)

% AUV model parameters; Fossen (2021, Section 8.4.2) and Allen et al. (2000)

% constants
mu = 63.446827;         % Lattitude for Trondheim, Norway (deg)
g_mu = gravity(mu);     % gravity vector (m/s2)

alpha = atan2( nu_r(3), nu_r(1) );                % angle of attack (rad)

if payload.shape == 'spheroid'
    % L_auv = AUV length (m)
    % D_auv = AUV diamater (m)
    % planform area S = 70% of rectangle L_auv * D_auv
    S = 0.7 * payload.L_auv * payload.D_auv; 

    a = payload.L_auv/2;    % spheroid semi-axes a and b
    b = payload.D_auv/2;                  
    r44 = 0.3;               % added moment of inertia in roll: A44 = r44 * Ix
    r_bg = [ 0 0 0.02 ]';    % CG w.r.t. to the CO
    r_bb = [ 0 0 0 ]';       % CB w.r.t. to the CO
    
    % Parasitic drag coefficient CD_0, i.e. zero lift and alpha = 0
    % F_drag = 0.5 * rho * Cd * (pi * b^2)   
    % F_drag = 0.5 * rho * CD_0 * S
    Cd = 0.42;                              % from Allen et al. (2000)
    CD_0 = Cd * pi * b^2 / S;

    % Rigid-body mass and hydrodynamic added mass
    [MRB,CRB] = spheroid(a,b,nu(4:6),r_bg);
    [MA,CA] = imlay61(a, b, nu_r, r44);


    % CA-terms in roll, pitch and yaw can destabilize the model if quadratic
    % rotational damping is missing. These terms are assumed to be zero
    CA(5,3) = 0; CA(3,5) = 0;  % quadratic velocity terms due to pitching
    CA(5,1) = 0; CA(1,5) = 0;  
    CA(6,1) = 0; CA(1,6) = 0;  % Munk moment in yaw 
    CA(6,2) = 0; CA(2,6) = 0;

    M = MRB + MA;
    C = CRB + CA;
    m = MRB(1,1); W = m * g_mu; B = W;


    % Low-speed linear damping matrix parameters
    T1 = 20;                 % time constant in surge (s)
    T2 = 20;                 % time constant in sway (s)
    zeta4 = 0.3;             % relative damping ratio in roll
    zeta5 = 0.8;             % relative damping ratio in pitch
    T6 = 1;                  % time constant in yaw (s)

    D = Dmtrx([T1 T2 T6],[zeta4 zeta5],MRB,MA,[W r_bg' r_bb']);
    D(1,1) = D(1,1) * exp(-3*U_r);   % vanish at high speed where quadratic
    D(2,2) = D(2,2) * exp(-3*U_r);   % drag and lift forces dominates

    tau_liftdrag = forceLiftDrag(payload.D_auv,S,CD_0,alpha,U_r);
    tau_crossflow = crossFlowDrag(payload.L_auv,payload.D_auv,payload.D_auv,nu_r);
    
    % J,R           rotation matrices
    [J,R] = eulerang(x(10),x(11),x(12));

    % Restoring forces and moments
    g = gRvect(W,B,R,r_bg,r_bb);
end
