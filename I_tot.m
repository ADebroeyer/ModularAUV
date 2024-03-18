function I = I_tot(I_mat)
% Function sums the moment of inertia of the bodies.
I=0;
for i = 1:length(I_mat)
    I=I+I_mat(i);
end
