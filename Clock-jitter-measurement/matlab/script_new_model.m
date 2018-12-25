%
%24/12/2018 add this new script.
% Simulate model from Chapter 13, page 552, 
Ts = 1/120
z = tf('z',Ts);
Gc = 150*(z-0.72)/(z+0.4);
Gp = 0.00133*(z+0.75)/(z*(z-1)*(z-0.72));
cl = feedback(Gc*Gp,1);
step(cl)
[A,B,C,D] = ssdata(cl);
%% 25/12/2018 Run simulation multiple time and save to response mat file

%set runtime for simulink model
runtime = 0.2;

%set number of runs
n_run = 10000;

%load clk source from hardware
file ='clk_Opi_1_120s_norm20181225230330.mat'; 
load(file);

%split clock source into different pattern enough for runtime.
clock_array_len = length(clk);

tic
pattern_index = find(clk(:,1)<runtime);
pattern = clk(pattern_index,:);

% pre-create memory to storage data.
sim('Tape_motion_dynamic');% run the first time to check the size of response data
if n_run*2>=clock_array_len
    Q2 ='CLOCK DATA IS TOO SHORT, PRESS CTRL+C NOW !';
    y =input(Q2);
else
    response = zeros(length(ScopeData1.time),n_run+1,'double');    
end


% first column is time axes
response(:,1)=ScopeData1.time;

for i=1:n_run
    
    %return each index pattern which enough for runtime.
    pattern = clk(pattern_index,:);
    
    %set 0 for the start value of time axe 
    pattern(:,1)=pattern(:,1)-pattern(1,1);
    
    %call simulink
    sim('Tape_motion_dynamic');
    %plot(ScopeData1.time,ScopeData1.signals.values);
    
    response(:,i+1) = ScopeData1.signals.values;
    
    %increase index to 2, we start from rising edge
    pattern_index = pattern_index +2;
end
save(strcat('response_',file),'response');
toc
%% test draw from matrix file
% load data from random jitter
file ='response_clk_Opi_1_120s_norm20181225230330.mat' ;
load(file);
% draw output response - RANDOM JITTER
tic
hold on
count=0
for i=2:length(response(1,:))
    plot(response(:,1),response(:,i));
    count = count +1
end
% format plot
xlabel('Time (s)')
% ylabel('Speed (rpm)')
title('ENVELOP OF OUTPUT RESPONSE')
% legend('NO JITTER','JITTER');%,'JITTER 20%','JITTER 30%','JITTER 40%','Location','southeast');
% set(gca,'FontSize',30)
%set(findall(gca, 'Type', 'Line'),'LineWidth',3);
hold off
grid on
% set(gcf, 'Position', [100, 100, 1280, 720])
%axis([0 inf 0 1.3])
clear response

formatOut = 'yyyymmddHHMMSS';
print(file(1:(end-4)),'-dpng')
toc