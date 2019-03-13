clear all; clc; close all

load newstage1
stage1 = RESULTS;
load newstage2
stage2 = RESULTS;
load newstage3
stage3 = RESULTS;
load newstage4
stage4 = RESULTS;
load newstagefixed20
stage20 = RESULTS;
load newstagefixed40
stage40 = RESULTS;
load newstagefixed80
stage80 = RESULTS;

clear RESULTS

%%
y = zeros(7,4001);
for j = 1:3
    z(j,1) = stage1(j).objectives(23,end);
    z(j,2) = stage2(j).objectives(23,end);
    z(j,3) = stage3(j).objectives(23,end);
    z(j,4) = stage4(j).objectives(23,end);
    z(j,5) = stage20(j).objectives(23,end);
    z(j,6) = stage40(j).objectives(23,end);
    z(j,7) = stage80(j).objectives(23,end);
    
    y(1,:) = y(1,:) + stage1(j).objectives(23,:);
    y(2,:) = y(2,:) + stage2(j).objectives(23,:);
    y(3,:) = y(3,:) + stage3(j).objectives(23,:);
    y(4,:) = y(4,:) + stage4(j).objectives(23,:);
    y(5,:) = y(5,:) + stage20(j).objectives(23,:);
    y(6,:) = y(6,:) + stage40(j).objectives(23,:);
    y(7,:) = y(7,:) + stage80(j).objectives(23,:);
    
    x(j,1) = stage1(j).clock.totalTime;
    x(j,2) = stage2(j).clock.totalTime;
    x(j,3) = stage3(j).clock.totalTime;
    x(j,4) = stage4(j).clock.totalTime;
    x(j,5) = stage20(j).clock.totalTime;
    x(j,6) = stage40(j).clock.totalTime;
    x(j,7) = stage80(j).clock.totalTime;
end

x=x/60;
y=y/3;

% figure()
% boxplot(x,{'stage1','stage2', 'stage3', 'stage4', 'fixed 20', 'fixed 40', 'fixed 80'})
% ylabel('runtime in minutes')

figure()
subplot(1,2,1)
plot(y')
legend('stage1','stage2', 'stage3', 'stage4', 'fixed 20', 'fixed 40', 'fixed 80')
xlabel('Iterations')
ylabel('Average costs in Euros')
axis([0 4000 2.5e5 5e5])

subplot(1,2,2)
boxplot(x,{'stage1','stage2', 'stage3', 'stage4', 'fixed 20', 'fixed 40', 'fixed 80'})
ylabel('costs in Euros')
xlabel('Amount of initial particles')
ylabel('Total runtime [minutes]')


figure()
subplot(1,2,1)
plot(stage1(2).objectives(23,:))
hold on
plot(stage1(2).objectives([1],:)')
hold off
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1')
xlabel('Iterations')
ylabel('Costs in Euros')
title('Stage 1 path relinking')

subplot(1,2,2)
plot(stage4(2).objectives(23,:))
hold on
plot(stage4(2).objectives([1],:)')
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1')
xlabel('Iterations')
ylabel('Costs in Euros')
title('Stage 4 path relinking')
%%
% plot(stage1.objectives(34,:))
% hold on
% plot(stage2.objectives(34,:))
% plot(stage3.objectives(34,:))
% plot(stage4.objectives(34,:))
%
% legend('stage1', 'stage2', 'stage3', 'stage4')
%
% figure()
% x(:,1) = stage1.clock.totalTime';
% x(:,2) = stage2.clock.totalTime';
% x(:,3) = stage3.clock.totalTime';
% x(:,4) = stage4.clock.totalTime';
% x=x/60;
%
% boxplot(x,{'stage1','stage2', 'stage3', 'stage4'})
% ylabel('runtime in minutes')
%
% figure()
% plot(stage4.objectives(34,:))
% hold on
% plot(all.objectives(34,1:5001))
% legend('Local pathrelinking', 'Global pathrelinking')