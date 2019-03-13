clear all; clc; close all

load threshholds11
threshholds(1).ResultDep = RESULTS;
load threshholds21
threshholds(2).ResultDep = RESULTS;
load threshholds31
threshholds(3).ResultDep = RESULTS;
load threshholds41
threshholds(4).ResultDep = RESULTS;
load threshholds51
threshholds(5).ResultDep = RESULTS;
load threshholds61
threshholds(6).ResultDep = RESULTS;
load threshholds71
threshholds(7).ResultDep = RESULTS;
load threshholds81
threshholds(8).ResultDep = RESULTS;
load threshholds91
threshholds(9).ResultDep = RESULTS;

load threshholds12
threshholds(1).ResultClean = RESULTS;
load threshholds22
threshholds(2).ResultClean = RESULTS;
load threshholds32
threshholds(3).ResultClean = RESULTS;
load threshholds42
threshholds(4).ResultClean = RESULTS;
load threshholds52
threshholds(5).ResultClean = RESULTS;
load threshholds62
threshholds(6).ResultClean = RESULTS;
load threshholds72
threshholds(7).ResultClean = RESULTS;
load threshholds82
threshholds(8).ResultClean = RESULTS;
load threshholds92
threshholds(9).ResultClean = RESULTS;
clear RESULTS

%%
close all

% Depots

for i = 1:9
    
    for j = 1:3
        z(j,i) = threshholds(i).ResultDep(j).objectives(23,end);
        x(j,i) = threshholds(i).ResultDep(j).clock.totalTime;
    end
end
meanz = mean(z,1);
x=x/60;

figure()
subplot(1,2,1)
xdep = [0 0.5 1 1.2 1.5 2 5 10 2000];
for j = 1:3
    plot(xdep,z(j,:))
    
    hold on
end
axis([0 20 2.7e5 3.2e5])
xlabel('Depot threshold')
ylabel('Costs in Euros')
title('Fixed cleaning threshold = 10')

subplot(1,2,2)
plot(xdep,meanz)
axis([0 20 2.7e5 3.2e5])
xlabel('Depot threshold')
ylabel('Average costs in Euros')
title('Fixed cleaning threshold = 10')

% Depots
for i = 1:9
    
    for j = 1:3
        y(j,i) = threshholds(i).ResultClean(j).objectives(23,end);
        x2(j,i) = threshholds(i).ResultClean(j).clock.totalTime;
    end
    
end
x2=x2/60;
meany = mean(y,1);

xclean = [0 0.5 1 2 3 5 10 20 2000];
figure()
subplot(1,2,1)
for j = 1:3
    plot(xclean,y(j,:))
    
    hold on
end
axis([0 20 2.7e5 3.2e5])
xlabel('Cleaning threshold')
ylabel('Costs in Euros')
title('Fixed depot threshold = 1.2')

subplot(1,2,2)
plot(xclean,meany)
axis([0 20 2.7e5 3.2e5])
xlabel('Cleaning threshold')
ylabel('Average costs in Euros')
title('Fixed depot threshold = 1.2')

figure()
subplot(1,2,1)
boxplot(z,cellstr(string(xdep)))
xlabel('Depot threshold')
ylabel('Costs in Euros')
title('Fixed cleaning threshold = 10')

subplot(1,2,2)
boxplot(y,cellstr(string(xclean)))
xlabel('Cleaning threshold')
ylabel('Costs in Euros')
title('Fixed depot threshold = 1.2')