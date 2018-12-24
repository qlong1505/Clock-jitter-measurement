%
%24/12/2018 add this new script.
% Simulate model from Chapter 13, page 552, 
Ts = 1/120
z = tf('z',Ts);
Gc = 150*(z-0.72)/(z+0.4);
Gp = 0.00133*(z+0.75)/(z*(z-1)*(z-0.72));
cl = feedback(Gc*Gp,1);
step(cl)