function [xdot,U] = main_Modular(x,ui,Vc,betaVc,w_c)

load("ModelParameters.mat") % Loades the model parameters

if (nargin == 2), Vc = 0; betaVc = 0; w_c = 0; end  % no ocean currents

%% Constants
mu = 63.446827;         % Lattitude for Trondheim, Norway (deg)
g_mu = gravity(mu);     % gravity vector (m/s2)
rho = 1026;             % density of water (m/s2)

%% State vectors and control inputs
nu = x(1:6); 
eta = x(7:12);
delta_r = ui(1);        % tail rudder (rad)
delta_s = ui(2);        % stern plane (rad)
n = ui(3)/60;           % propeller revolution (rps)

%% Ocean currents and relative speed
u_c = Vc * cos( betaVc - eta(6) );                               
v_c = Vc * sin( betaVc - eta(6) );   

nu_c = [u_c v_c w_c 0 0 0]';                  % ocean current velocities
Dnu_c = [nu(6)*v_c -nu(6)*u_c 0 0 0 0]';      % time derivative of nu_c

% Relative velocities/speed, angle of attack and vehicle speed
nu_r = nu - nu_c;                                 % relative velocity
alpha = atan2( nu_r(3), nu_r(1) );                % angle of attack (rad)
U_r = sqrt( nu_r(1)^2 + nu_r(2)^2 + nu_r(3)^2 );  % relative speed (m/s)
U  = sqrt( nu(1)^2 + nu(2)^2 + nu(3)^2 );         % speed (m/s)

%% Constructing the body/payload

payload(shape, L_auv, D_auv)


%% Constructing propellors

propellor(locations, directions, masses, I0_mat, n, n_max)

%% Constructing rudders

% gecomment voor testen nu 
% rudders(sat)

%% Propulsion vector

% TODO: plaatst dit deels in de apparte bestanden
[J,R] = eulerang(x(10),x(11),x(12));

% Generalized propulsion force vector
tau = zeros(6,1);                                
tau(1) = (1-t_prop) * X_prop + X_r + X_s;
tau(2) = Y_r;
tau(3) = Z_s;
tau(4) = K_prop / 10;  % scaled down by a factor of 10 to match exp. results
tau(5) = x_s * Z_s;
tau(6) = x_r * Y_r;

%% State-space model

% Dnu_c         derivative of current velocities
% M             mass + hydrodynamic added mass
% tau           propulsion
% tau_liftdrag  hydrodynamic lift and drag forces of a submerged 
%               "wing profile" for varying angle of attack
%tau_crossflow  cross-flow drag integrals for
%               a marine craft using strip theory.
% C             mass + hydrodynamic added damping
%               CA-terms in roll, pitch and yaw can destabilize the model if quadratic
%               rotational damping is missing. These terms are assumed to be zero
% nu_r          relative velocity
% D             linear damping matrix for marine craft
% J,R           rotation matrices
[J,R] = eulerang(x(10),x(11),x(12));
% g             vector of restoring 
%               forces about an arbitrarily point CO for a submerged body
g = gRvect(W,B,R,r_bg,r_bb);
% nu            state vector: x(1:6)

xdot = [ Dnu_c + M \ ...
            (tau + tau_liftdrag + tau_crossflow - C * nu_r - D * nu_r  - g)
         J * nu ]; 