clear all; clc; close all

load stage1
stage1 = RESULTS;
load stage2
stage2 = RESULTS;
load stage3
stage3 = RESULTS;
load stage4
stage4 = RESULTS;
load ../Structured/allNeighbors
all = RESULTS;
clear RESULTS

%%
plot(stage1.objectives(34,:))
hold on
plot(stage2.objectives(34,:))
plot(stage3.objectives(34,:))
plot(stage4.objectives(34,:))

legend('stage1', 'stage2', 'stage3', 'stage4')

figure()
x(:,1) = stage1.clock.totalTime';
x(:,2) = stage2.clock.totalTime';
x(:,3) = stage3.clock.totalTime';
x(:,4) = stage4.clock.totalTime';
x=x/60;

boxplot(x,{'stage1','stage2', 'stage3', 'stage4'})
ylabel('runtime in minutes')

figure()
plot(stage4.objectives(34,:))
hold on
plot(all.objectives(34,1:5001))
legend('Local pathrelinking', 'Global pathrelinking')