clear all; clc; close all

load branch2k
branch2k = RESULTS;
load branchhalfk
branchhalfk = RESULTS;
load branchk
branchk = RESULTS;
load branch20
branch20 = RESULTS;
clear RESULTS

%%
y = zeros(4,4001);
for j = 1:3
    z(j,1) = branch2k(j).objectives(23,end);
    z(j,2) = branchhalfk(j).objectives(23,end);
    z(j,3) = branchk(j).objectives(23,end);
    z(j,4) = branch20.objectives(23,end);
    
    y(1,:) = y(1,:) + branch2k(j).objectives(23,:);
    y(2,:) = y(2,:) + branchhalfk(j).objectives(23,:);
    y(3,:) = y(3,:) + branchk(j).objectives(23,:);
    y(4,:) = y(4,:) + branch20.objectives(23,:);
    
    x(j,1) = branch2k(j).clock.totalTime;
    x(j,2) = branchhalfk(j).clock.totalTime;
    x(j,3) = branchk(j).clock.totalTime;
    x(j,4) = branch20.clock.totalTime;
end

x=x/60;
y=y/3;

% figure()
% boxplot(x,{'stage1','stage2', 'stage3', 'stage4', 'fixed 20', 'fixed 40', 'fixed 80'})
% ylabel('runtime in minutes')

figure()
subplot(1,2,1)
plot(y')
legend('half k','k', '2 k', '20')
xlabel('Iterations')
ylabel('Average costs in Euros')
axis([0 4000 2.5e5 5e5])

subplot(1,2,2)
boxplot(x,{'half k','k', '2 k', '20'})
ylabel('costs in Euros')
xlabel('Amount of branches in pathrelinking stage')
ylabel('Total runtime [minutes]')
