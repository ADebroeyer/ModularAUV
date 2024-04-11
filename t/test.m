h = Aero.Animation;
idx1 = createBody(h,'pa24-250_orange.ac','Ac3d');
pos1 = h.Bodies{1}.Position;
rot1 = h.Bodies{1}.Rotation;
moveBody(h,1,pos1 + [0 0 -3],rot1);