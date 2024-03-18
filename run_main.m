% File for testing and debugging pourposes 
% easier to debug than simulink

clear;

x = [0 0 0 0 0 0 0 0 0 0 0 0]';

ui = [0 0 1500]';


%% USER INPUTS
h  = 0.02;                 % sample time (s)
N  = 50;                 % number of samples

simdata = zeros(N+1,length(x)+4); % allocate empty table for simulation data


for i = 1:N+1
    t = (i-1)*h; 

    xdot = main_Modular(x,ui);
    xdotr = remus100(x,ui);
    
    x = x + h * xdot; 
    xr = x + h * xdotr;

    % Store simulation data in a table 
    simdata(i,:) = [t ui' x'];   
    
    xdot' ~= xdotr'

    if max(xdot ~= xdotr)
        xdot
        xdotr
        i
    end
end


%% PLOTS
t       = simdata(:,1);         % simdata = [t z_d theta_d psi_d ui' x']
% z_d     = simdata(:,2); 
% theta_d = simdata(:,3); 
% psi_d   = simdata(:,4); 
% r_d     = simdata(:,5); 
u       = simdata(:,2:4); 
nu      = simdata(:,5:10);
eta = simdata(:,11:16);

figure(1); 
subplot(611),plot(t,nu(:,1))
xlabel('time (s)'),title('Surge velocity (m/s)'),grid
subplot(612),plot(t,nu(:,2))
xlabel('time (s)'),title('Sway velocity (m/s)'),grid
subplot(613),plot(t,nu(:,3))
xlabel('time (s)'),title('Heave velocity (m/s)'),grid
subplot(614),plot(t,rad2deg(nu(:,4)))
xlabel('time (s)'),title('Roll rate (deg/s)'),grid
subplot(615),plot(t,rad2deg(nu(:,5)))
xlabel('time (s)'),title('Pitch rate (deg/s)'),grid
% subplot(616),plot(t,rad2deg(nu(:,6)),t,rad2deg(r_d))
% legend('true','desired')
% xlabel('time (s)'),title('Yaw rate (deg/s)'),grid
set(findall(gcf,'type','line'),'linewidth',2)
set(findall(gcf,'type','text'),'FontSize',14)
set(findall(gcf,'type','legend'),'FontSize',16)



