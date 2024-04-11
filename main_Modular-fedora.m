function [xdot,U] = main_Modular(x,ui,Vc,betaVc,w_c)
% main function for which is calling all the modules
% called in the SIMULINK model: ModularSIM.slx and run_main.m
%
% Dnu_c         derivative of current velocities
% M             mass + hydrodynamic added mass
% tau           propulsion
% tau_liftdrag  hydrodynamic lift and drag forces of a submerged 
%               "wing profile" for varying angle of attack
% t au_crossflow  cross-flow drag integrals for
%               a marine craft using strip theory.
% C             mass + hydrodynamic added damping
%               CA-terms in roll, pitch and yaw can destabilize the model if quadratic
%               rotational damping is missing. These terms are assumed to be zero
% nu_r          relative velocity
% D             linear damping matrix for marine craft
% J,R           rotation matrices
% g             vector of restoring 
%               forces about an arbitrarily point CO for a submerged body
% xdot
% nu            state vector: x(1:6)

% S = load("ModelParameters.mat"); % 

if (nargin == 2), Vc = 0; betaVc = 0; w_c = 0; end  % no ocean currents

%% Constants
rho = 1026;             % density of water (m/s2)

%% State vectors and control inputs
nu = x(1:6); 
eta = x(7:12);
% commented untill rudder is added
% delta_r = ui(1);        % tail rudder (rad)
% delta_s = ui(2);        % stern plane (rad)
speeds = ui(3)/60;        % propeller revolution (rps)

%% Ocean currents and relative speed
u_c = Vc * cos( betaVc - eta(6) );                               
v_c = Vc * sin( betaVc - eta(6) );   

nu_c = [u_c v_c w_c 0 0 0]';                  % ocean current velocities
Dnu_c = [nu(6)*v_c -nu(6)*u_c 0 0 0 0]';      % time derivative of nu_c

% Relative velocities/speed, angle of attack and vehicle speed
nu_r = nu - nu_c;                                 % relative velocity
U  = sqrt( nu(1)^2 + nu(2)^2 + nu(3)^2 );         % speed (m/s)

%% Constructing the body/payload

[M, C, D, tau_liftdrag, tau_crossflow, J, g]  = payload(nu,nu_r, x);


%% Constructing propellors

[F_prop, M_prop] = propellor( speeds ,rho,U);


%% Constructing rudders

% commented for testing
% rudders(sat)

%% Balast 

% commented for testing
% B = W; balast function still has to be implemented

%% Propulsion vector

% Generalized propulsion force vector
tau = zeros(6,1);                                
tau(1) = F_prop(1);
tau(2) = F_prop(2);
tau(3) = F_prop(3);
tau(4) = M_prop(1);  % scaled down by a factor of 10 to match exp. results
tau(5) = M_prop(2);
tau(6) = M_prop(3);

xdot = [ Dnu_c + M \ ...
            (tau + tau_liftdrag + tau_crossflow - C * nu_r - D * nu_r - g);
         J * nu ]; 