clear all; clc; close all

load particle1
particle1 = RESULTS;
load particle10
particle10 = RESULTS;
load particle21
particle21 = RESULTS;
load particle32
particle32 = RESULTS;
clear RESULTS

%%

z = zeros(4,4001);

for i = 1:3
    x(i,1) = particle1(i).objectives(size(particle1(1).objectives,1),end);
    x(i,2) = particle10(i).objectives(size(particle10(1).objectives,1),end);
    x(i,3) = particle21(i).objectives(size(particle21(1).objectives,1),end);
    x(i,4) = particle32(i).objectives(size(particle32(1).objectives,1),end);
   
    y(i,1) = particle1(i).clock.totalTime;
    y(i,2) = particle10(i).clock.totalTime;
    y(i,3) = particle21(i).clock.totalTime;
    y(i,4) = particle32(i).clock.totalTime;
    
    z(1,:) = z(1,:) + particle1(i).objectives(size(particle1(1).objectives,1),:);
    z(2,:) = z(2,:) + particle10(i).objectives(size(particle10(1).objectives,1),:);
    z(3,:) = z(3,:) + particle21(i).objectives(size(particle21(1).objectives,1),:);
    z(4,:) = z(4,:) + particle32(i).objectives(size(particle32(1).objectives,1),:);
end 
z=z/3;
y=y/60;

figure()
boxplot(x,{'11','33', '66', '99'})
xlabel('Amount of initial particles')
ylabel('Costs in Euros after 4000 iterations')

figure()
boxplot(y,{'11','33', '66', '99'})
xlabel('Amount of initial particles')
ylabel('Total runtime [minutes]')

figure()
plot(z')
xlabel('Iterations')
ylabel('Average costs in Euros')
legend('11','33', '66', '99')
axis([0 4000 2.5e5 5e5])

%%
% close all; clc
% [~,I] = min(x)
% temp = [randperm(3);randperm(3);randperm(3);randperm(3)];
% I=temp(:,1)';
% 
% z(1,:) = particle1(I(1)).objectives(size(particle1(1).objectives,1),:);
% z(2,:) = particle10(I(2)).objectives(size(particle10(1).objectives,1),:);
% z(3,:) = particle21(I(3)).objectives(size(particle21(1).objectives,1),:);
% z(4,:) = particle32(I(4)).objectives(size(particle32(1).objectives,1),:);
% 


%%


% plot(particle1.objectives(34,:))
% hold on
% plot(particle2.objectives(34,:))
% plot(particle3.objectives(34,:))
% plot(particle4.objectives(34,:))
% 
% legend('stage1', 'stage2', 'stage3', 'stage4')
% % 
% % x(:,1) = stage1.clock.iterationTime';
% % x(:,2) = stage2.clock.iterationTime';
% % x(:,3) = stage3.clock.iterationTime';
% % x(:,4) = stage4.clock.iterationTime';
% % boxplot(x,{'stage1','stage2', 'stage3', 'stage4'})