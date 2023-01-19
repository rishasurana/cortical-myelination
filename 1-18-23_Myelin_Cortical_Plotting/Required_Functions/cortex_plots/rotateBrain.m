function brain = rotateBrain(brain,axis,th)
if     axis == 'x'
    R = [1        0       0       0;  0       cos(th) sin(th) 0; 0      -sin(th) cos(th) 0; 0 0 0 1]; % rotate about x
elseif axis == 'y'
    R = [cos(th)  0      -sin(th) 0;  0       1       0       0; sin(th) 0       cos(th) 0; 0 0 0 1]; % rotate about y
elseif axis == 'z'
    R = [cos(th ) sin(th) 0       0; -sin(th) cos(th) 0       0; 0       0       1       0; 0 0 0 1]; % rotate about z
end
brain = R*brain;
return