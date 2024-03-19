function [F_prop, M_prop] = propellor(speeds, rho,U)
% function for making the different propellors 
% called in main_modular
    
S = load("PropParameters.mat");
prop = S.prop;

X_prop = zeros(size(speeds));
K_prop = zeros(size(speeds));
    
    for i=1:length(speeds)
        n = speeds(i);
        % Amplitude saturation of the control signals
        prop.speeds_max = 1525;        % maximum propeller rpm        
        if (abs(n) > prop.max_speeds(i)), n = sign(n) * prop.max_speeds(i); end
        
        %%%%%%%%% TO DO deze ingeven door de user
        % Propeller coeffs. KT and KQ are computed as a function of advance no.
        % Ja = Va/(n*D_prop) where Va = (1-w)*U = 0.944 * U; Allen et al. (2000)
        D_prop = 0.14;   % propeller diameter corresponding to 5.5 inches
        Va = 0.944 * U;  % advance speed (m/s)
        
        
        % Ja_max = 0.944 * 2.5 / (0.14 * 1525/60) = 0.6632
        Ja_max = 0.6632;
        
        % Single-screw propeller with 3 blades and blade-area ratio = 0.718.    
        % >> [KT_0, KQ_0] = wageningen(0,1,0.718,3)
        KT_0 = 0.4566;
        KQ_0 = 0.0700;
        % >> [KT_max, KQ_max] = wageningen(0.6632,1,0.718,3) 
        KT_max = 0.1798;
        KQ_max = 0.0312;
        
        
        % Propeller thrust and propeller-induced roll moment
        % Linear approximations for positive Ja values
        % KT ~= KT_0 + (KT_max-KT_0)/Ja_max * Ja   
        % KQ ~= KQ_0 + (KQ_max-KQ_0)/Ja_max * Ja        
        if n > 0   % forward thrust
        
            X_prop(i) = rho * D_prop^4 * (... 
                KT_0 * abs(n) * n + (KT_max-KT_0)/Ja_max * (Va/D_prop) * abs(n) );        
            K_prop(i) = rho * D_prop^5 * (...
                KQ_0 * abs(n) * n + (KQ_max-KQ_0)/Ja_max * (Va/D_prop) * abs(n) );           
                    
        else       % reverse thrust (braking)
                
            X_prop(i) = rho * D_prop^4 * KT_0 * abs(n) * n; 
            K_prop(i) = rho * D_prop^5 * KQ_0 * abs(n) * n;
                    
        end   
       
        t_prop = 0.1;    % thrust deduction number

        F_prop = (1-t_prop)*X_prop .* prop.directions; % Should we also account for the orientation of the vehicle (x)?

        M_prop = zeros(3,length(speeds));
        for i=1:length(prop.masses)
            M_prop(:,i) = K_prop/10 .* prop.directions + -X_prop * (cross(prop.locations(:,i),prop.directions(:,i)));
        end % Scaled with a factor of 10 to match experimental results
                % Te kijken of kolommen of rijen
        F_prop = sum(F_prop,2);
        M_prop = sum(M_prop,2);

    end

end