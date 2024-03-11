function [mass, I_prop_tot, CoG, X_prop, K_prop] = propellor(locations, directions, masses, I0_mat, n, n_max)
    
    
    
    
    
    
    % misschien opsplitsen in eerste run en tweede
    
    
    
    for i=1:length(speeds)
        
        % Amplitude saturation of the control signals
        n_max = 1525;                                   % maximum propeller rpm
        
        if (abs(n) > max_ui(3)), n = sign(n) * max_ui(3); end
        
        %%%%%%%%% TO DO deze ingeven door de user
        % Propeller coeffs. KT and KQ are computed as a function of advance no.
        % Ja = Va/(n*D_prop) where Va = (1-w)*U = 0.944 * U; Allen et al. (2000)
        D_prop = 0.14;   % propeller diameter corresponding to 5.5 inches
        t_prop = 0.1;    % thrust deduction number
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
        
            X_prop = rho * D_prop^4 * (... 
                KT_0 * abs(n) * n + (KT_max-KT_0)/Ja_max * (Va/D_prop) * abs(n) );        
            K_prop = rho * D_prop^5 * (...
                KQ_0 * abs(n) * n + (KQ_max-KQ_0)/Ja_max * (Va/D_prop) * abs(n) );           
                    
        else       % reverse thrust (braking)
                
            X_prop = rho * D_prop^4 * KT_0 * abs(n) * n; 
            K_prop = rho * D_prop^5 * KQ_0 * abs(n) * n;
                    
        end   
    
        % inspired by spheroid
        O3 = zeros(3,3);
        % moment of inertia
        Ix = 0;
        Iy = 0;
        Iz = 0;
        Ig = diag([Ix Iy Iz]);
        
        nu2 = [0 0];
    
        % rigid-body matrices expressed in the CG
        MRB_CG = diag([ m m m Ix Iy Iz ]);
        CRB_CG = [ m * Smtrx(nu2)    O3
               O3               -Smtrx(Ig*nu2) ];
        
        
    
    if n > 0   % forward thrust
    
        X_prop = rho * D_prop^4 * (... 
            KT_0 * abs(n) * n + (KT_max-KT_0)/Ja_max * (Va/D_prop) * abs(n) );        
        K_prop = rho * D_prop^5 * (...
            KQ_0 * abs(n) * n + (KQ_max-KQ_0)/Ja_max * (Va/D_prop) * abs(n) );           
                
    else       % reverse thrust (braking)
            
        X_prop = rho * D_prop^4 * KT_0 * abs(n) * n; 
        K_prop = rho * D_prop^5 * KQ_0 * abs(n) * n;
                
    end
    

    
    end
    
    % Calculating the masses and inertias
    
    mass = sum(masses);
    CoG = center_oG(locations,masses);
    
    I_mat = [];
    for i = 1:length(masses)
        I_mat(i) = steiner(I0_mat(i),masses(i),locations(i)); % Miscchien moet het hier - locations zijn
    end
    I_prop_tot = I_tot(I_mat);


end