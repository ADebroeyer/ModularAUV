function CoG = center_oG(locations,masses)
% Function calculates the center of gravity using the matrix of mass
% locations and vectors.
CoG = locations.*masses/sum(masses);
