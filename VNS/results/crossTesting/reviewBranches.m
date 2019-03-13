clear all; clc; close all

load crossk
crossk = RESULTS;
load cross2k
cross2k = RESULTS;
load cross4k
cross4k = RESULTS;
load cross50
cross50 = RESULTS;
load cross80
cross80 = RESULTS;
clear RESULTS

%%
y = zeros(5,4001);
for j = 1:3
    z(j,1) = crossk(j).objectives(23,end);
    z(j,2) = cross2k(j).objectives(23,end);
    z(j,3) = cross4k(j).objectives(23,end);
    z(j,4) = cross50(j).objectives(23,end);
    z(j,5) = cross80(j).objectives(23,end);
    
    y(1,:) = y(1,:) + crossk(j).objectives(23,:);
    y(2,:) = y(2,:) + cross2k(j).objectives(23,:);
    y(3,:) = y(3,:) + cross4k(j).objectives(23,:);
    y(4,:) = y(4,:) + cross50(j).objectives(23,:);
    y(5,:) = y(5,:) + cross80(j).objectives(23,:);
    
    x(j,1) = crossk(j).clock.totalTime;
    x(j,2) = cross2k(j).clock.totalTime;
    x(j,3) = cross4k(j).clock.totalTime;
    x(j,4) = cross50(j).clock.totalTime;
    x(j,5) = cross80(j).clock.totalTime;
end

x=x/60;
y=y/3;

% figure()
% boxplot(x,{'stage1','stage2', 'stage3', 'stage4', 'fixed 20', 'fixed 40', 'fixed 80'})
% ylabel('runtime in minutes')

figure()
subplot(1,2,1)
boxplot(z,{'k','2 k', '4 k', '50', '80'})
ylabel('Costs in Euros')
xlabel('Amount of cross exchanges')
% plot(y')
% legend('k','2 k', '4 k', '50', '80')
% xlabel('Iterations')
% ylabel('Average costs in Euros')
% axis([0 4000 2.5e5 5e5])

subplot(1,2,2)
boxplot(x,{'k','2 k', '4 k', '50', '80'})
xlabel('Amount of cross exchanges')
ylabel('Total runtime [minutes]')
