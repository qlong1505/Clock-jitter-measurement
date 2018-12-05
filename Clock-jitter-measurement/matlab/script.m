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
file = {'acq0001.csv',...
    'acq0002.csv',...
    'acq0003.csv',...
    'acq0004.csv',...
    'acq0005.csv',...
    'acq0006.csv',...
    'acq0007.csv',...
    'acq0008.csv',...
    'acq0009.csv',...
    'acq0010.csv'};
total_jitter=[];
for i=1:length(file)
    data=readtable(file{i})
    V = data.Channel1_V_;
    T = data.Time_s_;
    jitter = process(V,T);
    total_jitter = [total_jitter;jitter];
end
histogram(total_jitter(total_jitter<0.5),50);
%%
