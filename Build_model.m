% Script that takes user input for making the modle
clear;


ModularModel = input("Modular model ? [y/n]","s");

if ModularModel == "y"
% Ask the parameters of the model to the user

%list of questions
% 1. amout of props, loc. , dir. 
% 2. payload shape, dimensions, weight eventualy 

disp("not yet implemented")

else
clear;
% Default to the parameters for the remus model


% Propellors
locations = [[0,0,0]']; % locations of the propellors
% directions also with angles
% Normalize it
directions = [[1,0,0]']; % directions of the propellors (direction of flow)
masses_prop = [0]; % masses
I0_mat = zeros(3);
n_max = 1525; % saturation of propellor

m = 0;

% Payload
shape = 'spheroid';
L_auv = 1.6;             % AUV length (m)
D_auv = 0.19;            % AUV diamater (m)

% Rudder



% Ballast




end

% Initialisation of the constant parameters

% Propellor

% Calculating the masses and inertias  
I_mat = zeros(3);
for i = 1:length(masses_prop)
    % rigid-body matrices expressed in the CG
    Ix = 0;Iy = 0;Iz = 0; % moment of inertia
    Ig = diag([Ix Iy Iz]);
    MRB_CG = diag([ m m m Ix Iy Iz ]);
    
    mass_prop = sum(masses_prop);
    % Watch out with CoG
    CoG_prop = center_oG(locations,masses_prop);

    %I_mat(i) = steiner(I0_mat(i),masses_prop(i),locations(i)); % Mischien moet het hier - locations zijn
    I_mat = steiner(I0_mat,masses_prop,locations); % Mischien moet het hier - locations zijn
end
I_prop_tot = I_tot(I_mat);



save("ModelParameters.mat") % saves the workspace variables to given location


% Build the Simulink file
% Maybe run the Simulink file