file = 'data.csv';
x = csvread(file);
histogram(x,1000)
mean
%%
meanx = mean(x);
x = x(x<1.1*meanx & x>0.9*meanx);
histogram(x,30);