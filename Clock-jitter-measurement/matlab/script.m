file = 'acq0003.csv';
% x = csvread(file);
x = readtable(file)
%%
histogram(x,1000)
mean
%%
meanx = mean(x);
x = x(x<1.1*meanx & x>0.9*meanx);
histogram(x,30);

%% histogram of hardware measure jitter
folder ={'1ms_bb_high_priority','1ms_bb_normal_priority','1ms_bb_low_priority';...
    '1ms_rasp_high_priority','1ms_rasp_normal_priority','1ms_rasp_low_priority'}

Q1 = 'Which platform?\n1.Beagle Bone Black (single core)\n2.Raspberry pi (multi cores)\n';
x = input(Q1);
Q2 ='Choose priority level:\n1.High\n2.Normal\n3.Low\n'
y =input(Q2);
file = listACQ(folder{x,y});

total_jitter=[];
for i=1:length(file)
    data=readtable(file{i})
    V = data.Channel1_V_;
    T = data.Time_s_;
    jitter = process(V,T);
    total_jitter = [total_jitter;jitter];
end
histogram(total_jitter,50);
set(gca,'YScale','log')
hold on

% normal distribution with mean is 1ms
%     x = normrnd(0.001,std(total_jitter),length(total_jitter),1);
%     histogram(x,50);
%     set(gca,'YScale','log')

% Normal distribution with mean is data mean
x = normrnd(mean(total_jitter),std(total_jitter),length(total_jitter),1);
histogram(x,50);
set(gca,'YScale','log')

% Half normal distribution
%         pd2 = makedist('HalfNormal','mu',mean(total_jitter),'sigma',std(total_jitter));
%         x = random(pd2,length(total_jitter),1)
%         histogram(x,50);
%         set(gca,'YScale','log')

hold off
%%
Q1 = 'Which platform?\n1.Beagle Bone Black (single core)\n2.Raspberry pi (multi cores)\n';
x = input(Q1);
Q2 ='Choose priority level:\n1.High\n2.Normal\n3.Low'
y =input(Q2);
folder{x,y}
%%
folder ={'1ms_bb_high_priority','1ms_bb_normal_priority','1ms_bb_low_priority';...
    '1ms_rasp_high_priority','1ms_rasp_normal_priority','1ms_rasp_low_priority'}

%%
pd2 = makedist('HalfNormal','mu',mean(total_jitter),'sigma',std(total_jitter));
x = random(pd2,length(total_jitter),1)