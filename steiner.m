function I = steiner(I0,mass,location)
% Function translates the moment of inertia of a body to an arbitrary point in space. For a point mass, use I0 = 0.
R = [0;0;0]-location;    % Column vector from the center-of-mass to the origin
I = I0 + mass.*(dot(R,R)*eye(3,3) - R*R');