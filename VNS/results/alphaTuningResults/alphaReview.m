clear all; clc; close all

load alpha10
alpha10 = RESULTS;
load alpha50
alpha50 = RESULTS;
load alpha100
alpha100 = RESULTS;
load alpha200
alpha200 = RESULTS;
load alpha500
alpha500 = RESULTS;
load alpha1000
alpha1000 = RESULTS;
clear RESULTS

%%
figure()
hold on
plot(alpha10.objectives(34,1:4000))
plot(alpha50.objectives(34,1:4000))
plot(alpha100.objectives(34,1:4000))
plot(alpha200.objectives(34,1:4000))
plot(alpha500.objectives(34,1:4000))
plot(alpha1000.objectives(34,1:4000))
hold off
legend("alpha = 10","alpha = 50","alpha = 100","alpha = 200","alpha = 500","alpha = 1000");
