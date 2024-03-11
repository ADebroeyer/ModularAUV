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
% Default to the parameters for the remus model

% Propellors

% locations of the propellors
locations = [[0,0,0]'];
% directions of the propellors (direction of flow)
directions = [[1,0,0]'];
% masses
masses = [1];
I0_mat = ones(3);
%saturation of propellor
n_max = 1525;

% Payload

shape = 'spheroid';
L_auv = 1.6;             % AUV length (m)
D_auv = 0.19;            % AUV diamater (m)


% Rudder



% Ballast




end

% Initialisation of the constant parameters



save("ModelParameters.mat") % saves the workspace variables to given location

% Build the Simulink file

% Maybe run the Simulink file