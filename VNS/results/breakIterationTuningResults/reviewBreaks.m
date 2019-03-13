clear all; clc; close all

load break0
result0 = RESULTS;
load break100
result100 = RESULTS;
load break300
result300 = RESULTS;
load break600
result600 = RESULTS;
load break1000
result1000 = RESULTS;
clear RESULTS


plot(result0.objectives(34,:))
hold on
plot(result100.objectives(34,:))
plot(result300.objectives(34,:))
plot(result600.objectives(34,:))
plot(result1000.objectives(34,:))
xlabel('Iterations')
ylabel('Costs in Euros')
axis([0 5000 2.5e5 5e5])
legend('no breakpoint', '100', '300', '600', '1000')
hold off

figure()
subplot(1,2,1)
plot(result100.objectives(34,:))
hold on
plot(result100.objectives([1 33],:)')
hold off
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1', 'particle 33')
xlabel('Iterations')
ylabel('Costs in Euros')
title('breakpoint at 100 iterations')

subplot(1,2,2)
plot(result300.objectives(34,:))
hold on
plot(result300.objectives([1 33],:)')
axis([0 5000 2.5e5 5e5])
legend('Best particle', 'particle 1', 'particle 33')
xlabel('Iterations')
ylabel('Costs in Euros')
title('breakpoint at 300 iterations')

% figure()
% plot(result300.meanSimilarity)
% 
% figure()
% plot(result100.meanSimilarity)
%%
iterations= 5001;
inc = -100*diff(result300.objectives(34,:))./result300.objectives(34,1:end-1);
out = accumarray(ceil((1:numel(inc))/50)',inc(:),[],@mean);
out = resample(out,50,1);
% figure()
% plot(out);
% axis([0 iterations 0 max(out)*1.2+0.00001])
% 
% allpos = inc(inc > 0);
% figure()
% histogram(allpos)


% meanSim = result300.meanSimilarity;
% allpos = inc(inc > 0.0001);
% allSim = meanSim(inc > 0.0001);
% figure()
% qqplot(allSim,allpos')
% [R p]=corrcoef(allSim,allpos')
