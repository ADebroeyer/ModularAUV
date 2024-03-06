function [xdot] = remus100_copy(x,ui)
% Remus 100 AUV model based on remus100.m 
% function for (Fossen,2021)
% x = [ u v w p q r x y z phi theta psi ]'
% ui = [ delta_r delta_s n ]'
% Dependencies: spheroid,imlay61

if (length(x) ~= 12)
    error('x-vector must have dimension 12 or 13'); 
end

% Constants
g = 9.81;     % gravity vector (m/s2)
rho = 1026;   % density of water (m/s2)

% State vectors and control inputs
nu = x(1:6); 
eta = x(7:12);
delta_r = ui(1);        % tail rudder (rad)
delta_s = ui(2);        % stern plane (rad)
n = ui(3)/60;           % propeller revolution (rps)

% Amplitude saturation of the control signals
n_max = 1525;                                   % maximum propeller rpm
max_ui = [deg2rad(20) deg2rad(20) n_max/60]';   % deg, deg, rps

if (abs(delta_r) > max_ui(1)), delta_r = sign(delta_r) * max_ui(1); end
if (abs(delta_s) > max_ui(2)), delta_s = sign(delta_s) * max_ui(2); end
if (abs(n)       > max_ui(3)), n = sign(n) * max_ui(3); end

U  = sqrt( nu(1)^2 + nu(2)^2 + nu(3)^2 );         % speed (m/s)

% AUV model parameters; Fossen (2021, Section 8.4.2) and Allen et al. (2000)
L_auv = 1.6;             % AUV length (m)
D_auv = 0.19;            % AUV diamater (m)
S = 0.7 * L_auv * D_auv; % planform area S = 70% of rectangle L_auv * D_auv
a = L_auv/2;             % spheroid semi-axes a and b
b = D_auv/2;         

r44 = 0.3;               % added moment of inertia in roll: A44 = r44 * Ix
% Commented until undrestood

r_bg = [ 0 0 0.02 ]';    % CG w.r.t. to the CO
r_bb = [ 0 0 0 ]';       % CB w.r.t. to the CO

% Parasitic drag coefficient CD_0, i.e. zero lift and alpha = 0
% F_drag = 0.5 * rho * Cd * (pi * b^2)   
% F_drag = 0.5 * rho * CD_0 * S
Cd = 0.42;                              % from Allen et al. (2000)
CD_0 = Cd * pi * b^2 / S;

% Propeller coeffs. KT and KQ are computed as a function of advance no.
% Ja = Va/(n*D_prop) where Va = (1-w)*U = 0.944 * U; Allen et al. (2000)
D_prop = 0.14;   % propeller diameter corresponding to 5.5 inches
t_prop = 0.1;    % thrust deduction number
Va = 0.944 * U;  % advance speed (m/s)

% Ja_max = 0.944 * 2.5 / (0.14 * 1525/60) = 0.6632
Ja_max = 0.6632;

% Single-screw propeller with 3 blades and blade-area ratio = 0.718.    
% >> [KT_0, KQ_0] = wageningen(0,1,0.718,3)
KT_0 = 0.4566;
KQ_0 = 0.0700;
% >> [KT_max, KQ_max] = wageningen(0.6632,1,0.718,3) 
KT_max = 0.1798;
KQ_max = 0.0312;

% Propeller thrust and propeller-induced roll moment
% Linear approximations for positive Ja values
% KT ~= KT_0 + (KT_max-KT_0)/Ja_max * Ja   
% KQ ~= KQ_0 + (KQ_max-KQ_0)/Ja_max * Ja       
if n > 0   % forward thrust
    X_prop = rho * D_prop^4 * (... 
        KT_0 * abs(n) * n + (KT_max-KT_0)/Ja_max * (Va/D_prop) * abs(n) );        
    K_prop = rho * D_prop^5 * (...
        KQ_0 * abs(n) * n + (KQ_max-KQ_0)/Ja_max * (Va/D_prop) * abs(n) );                      
else       % reverse thrust (braking)      
    X_prop = rho * D_prop^4 * KT_0 * abs(n) * n; 
    K_prop = rho * D_prop^5 * KQ_0 * abs(n) * n;          
end        

S_fin = 0.00665;         % fin area

% Tail rudder
CL_delta_r = 0.5;        % rudder lift coefficient (-)
A_r = 2 * S_fin;         % rudder area (m2)
x_r = -a;                % rudder x-position (m)

% Stern plane (double)
CL_delta_s = 0.7;        % stern-plane lift coefficient (-)
A_s = 2 * S_fin;         % stern-plane area (m2)
x_s = -a;  


%%%%%%%%%%%%% Deze parameters niet modulair TODO %%%%%%%%%%%%%%%%%
% Low-speed linear damping matrix parameters
T1 = 20;                 % time constant in surge (s)
T2 = 20;                 % time constant in sway (s)
zeta4 = 0.3;             % relative damping ratio in roll
zeta5 = 0.8;             % relative damping ratio in pitch
T6 = 1;                  % time constant in yaw (s)

% Rigid-body mass and hydrodynamic added mass
[MRB,CRB] = spheroid(a,b,nu(4:6),r_bg);
[MA,CA] = imlay61(a, b, nu, r44);

%%%%%%%%%%%%%% TO DO betere analyse wrm vallen deze weg %%%%%%%%%%%
% CA-terms in roll, pitch and yaw can destabilize the model if quadratic
% rotational damping is missing. These terms are assumed to be zero
CA(5,3) = 0; CA(3,5) = 0;  % quadratic velocity terms due to pitching
CA(5,1) = 0; CA(1,5) = 0;  
CA(6,1) = 0; CA(1,6) = 0;  % Munk moment in yaw 
CA(6,2) = 0; CA(2,6) = 0;

M = MRB + MA;
C = CRB + CA;
m = MRB(1,1); W = m * g; B = W;

D = Dmtrx([T1 T2 T6],[zeta4 zeta5],MRB,MA,[W r_bg' r_bb']);
D(1,1) = D(1,1) * exp(-3*U);   % vanish at high speed where quadratic
D(2,2) = D(2,2) * exp(-3*U);   % drag and lift forces dominates

tau_liftdrag = forceLiftDrag(D_auv,S,CD_0,0,U);
tau_crossflow = crossFlowDrag(L_auv,D_auv,D_auv,nu);

[J,R] = eulerang(x(10),x(11),x(12));

% Restoring forces and moments
g = gRvect(W,B,R,r_bg,r_bb);

% Horizontal- and vertical-plane speed
U_h = sqrt( nu(1)^2 + nu(2)^2 );  
U_v = sqrt( nu(1)^2 + nu(3)^2 );

% Rudder and stern-plane drag
X_r = -0.5 * rho * U_h^2 * A_r * CL_delta_r * delta_r^2; 
X_s = -0.5 * rho * U_v^2 * A_s * CL_delta_s * delta_s^2;

% Rudder sway force 
Y_r = -0.5 * rho * U_h^2 * A_r * CL_delta_r * delta_r;

% Stern-plane heave force
Z_s = -0.5 * rho * U_v^2 * A_s * CL_delta_s * delta_s;

% Generalized propulsion force vector
tau = zeros(6,1);                                
tau(1) = (1-t_prop) * X_prop + X_r + X_s;
tau(2) = Y_r;
tau(3) = Z_s;
tau(4) = K_prop / 10;  % scaled down by a factor of 10 to match exp. results
tau(5) = x_s * Z_s;
tau(6) = x_r * Y_r;

% State-space model
xdot = [ nu + M \ ...
            (tau + tau_liftdrag + tau_crossflow - C * nu - D * nu  - g)
         J * nu ]; 
end