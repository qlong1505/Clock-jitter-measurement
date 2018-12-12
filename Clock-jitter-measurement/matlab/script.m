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
    if x==1
        V = data.Channel1_V_;
    end
    if x==2
        V = data.Channel2_V_;
    end
    T = data.Time_s_;
    jitter  = process(V,T);
    total_jitter = [total_jitter;jitter];
end

clk = clock_generator(total_jitter);


histogram(total_jitter,50);
set(gca,'YScale','log')
xlabel('Value') 
ylabel('Counts') 
hold on

% normal distribution with mean is 1ms
%     x = normrnd(0.001,std(total_jitter),length(total_jitter),1);
%     histogram(x,50);
%     set(gca,'YScale','log')

% Normal distribution with mean is data mean
%     x = normrnd(mean(total_jitter),std(total_jitter),length(total_jitter),1);
%     histogram(x,50);
%     set(gca,'YScale','log')

% Half normal distribution
%         pd2 = makedist('HalfNormal','mu',mean(total_jitter),'sigma',std(total_jitter));
%         x = random(pd2,length(total_jitter),1)
%         histogram(x,50);
%         set(gca,'YScale','log')

hold off
formatOut = 'yyyymmddHHMMSS';
print(strcat('hist_',folder{x,y},datestr(now,formatOut)),'-dpng')
save(strcat('clk_',folder{x,y},datestr(now,formatOut)),'clk')
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

%% open loop step response - load data
OLdata=readtable('open_loop.csv');
%%
load('open_loop.mat');
%%
T = OLdata.Time_s_(OLdata.Time_s_>=0);
EncoderA = OLdata.Channel1_V_(find(OLdata.Time_s_>=0));
EncoderB = OLdata.Channel2_V_(find(OLdata.Time_s_>=0));
%
EncoderA(EncoderA<1.5)=0;
EncoderA(EncoderA>=1.5)=1;
EncoderA = diff(EncoderA);
EncoderA(EncoderA==-1)=1;

EncoderB(EncoderB<1.5)=0;
EncoderB(EncoderB>=1.5)=1;
EncoderB = diff(EncoderB);
EncoderB(EncoderB==-1)=1;

T1 = T(find(EncoderA==1));
T2 = T(find(EncoderB==1));
%
T = zeros(length(T1)+length(T2),1);
T(1:2:end)=T1;
T(2:2:end)=T2;
%
T = diff(T);
T = diff(T2);
%
Speed = T*24;
%
Speed = 1./Speed;
Speed = Speed*60; %rpm
%
T = cumsum(T);
%
plot(T(T<0.5),Speed(find(T<0.5)));
%%
K = 4543/5;
tau = 0.042
sys = tf(K,[tau 1])
step(sys*5)