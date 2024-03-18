function [X_r,X_s,Y_r,Z_s] = rudders(sat,rho)

    % Tail rudder
    CL_delta_r = 0.5;        % rudder lift coefficient (-)
    A_r = 2 * S_fin;         % rudder area (m2)
    x_r = -a;                % rudder x-position (m)
    
    % Stern plane (double)
    CL_delta_s = 0.7;        % stern-plane lift coefficient (-)
    A_s = 2 * S_fin;         % stern-plane area (m2)
    x_s = -a;                % stern-plane z-position (m)



    % Rudder and stern-plane drag
    X_r = -0.5 * rho * U_rh^2 * A_r * CL_delta_r * delta_r^2; 
    X_s = -0.5 * rho * U_rv^2 * A_s * CL_delta_s * delta_s^2;
    
    % Rudder sway force 
    Y_r = -0.5 * rho * U_rh^2 * A_r * CL_delta_r * delta_r;
    
    % Stern-plane heave force
    Z_s = -0.5 * rho * U_rv^2 * A_s * CL_delta_s * delta_s;
end
