clear all; clc; close all

load no_sim
nosim = RESULTS;
load sim
sim = RESULTS;
clear RESULTS

%%
y=zeros(2,4001);
for i = 1:3
    x(i,1) = nosim(i).objectives(23,end);
    x(i,2) = sim(i).objectives(23,end);
    
    y(1,:) = y(1,:) + nosim(i).objectives(23,:);
    y(2,:) = y(2,:) + sim(i).objectives(23,:);
    
    z(i,1) = nosim(i).clock.totalTime;
    z(i,2) = sim(i).clock.totalTime;
end
y=y/3;

figure()
subplot(1,2,1)
plot(y')
legend('No similarity','With similarity')
xlabel('Iterations')
ylabel('Average costs in Euros')
axis([0 4000 2.5e5 5e5])

subplot(1,2,2)
boxplot(z,{'No similarity','With similarity'})
ylabel('costs in Euros')
xlabel('Amount of initial particles')
ylabel('Total runtime [minutes]')

figure()
subplot(1,2,1)
plot(nosim(2).objectives(23,:))
hold on
plot(nosim(2).objectives([1],:)')
hold off
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1')
xlabel('Iterations')
ylabel('Costs in Euros')
title('No similarity comparison')

subplot(1,2,2)
plot(sim(2).objectives(23,:))
hold on
plot(sim(2).objectives([1],:)')
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1')
xlabel('Iterations')
ylabel('Costs in Euros')
title('With similarity comparison')

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