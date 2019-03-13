clear all; clc; close all

load type1
type1 = RESULTS;
load type2
type2 = RESULTS;
load type3
type3 = RESULTS;
load type4
type4 = RESULTS;
clear RESULTS

%%

z = zeros(4,5001);
for i = 1:5
    x(i,1) = type1(i).objectives(19,end);
    x(i,2) = type2(i).objectives(19,end);
    x(i,3) = type3(i).objectives(19,end);
    x(i,4) = type4(i).objectives(19,end);
    
    z(1,:) = z(1,:) + type1(i).objectives(19,:);
    z(2,:) = z(2,:) + type2(i).objectives(19,:);
    z(3,:) = z(3,:) + type3(i).objectives(19,:);
    z(4,:) = z(4,:) + type4(i).objectives(19,:);
   
end 
z=z/5;

boxplot(x,{'type 1','type 2', 'type 3', 'type 4'})
xlabel('Types of initial 15 particles')
ylabel('Costs in Euros after 5000 iterations')

[~,I] = min(x);

y(1,:) = type1(I(1)).objectives(19,:);
y(2,:) = type2(I(2)).objectives(19,:);
y(3,:) = type3(I(3)).objectives(19,:);
y(4,:) = type4(I(4)).objectives(19,:);

figure()
plot(z')
legend('type 1','type 2', 'type 3', 'type 4')
xlabel('Iterations')
ylabel('Average costs in Euros')
axis([0 5000 2.8e5 5e5])
