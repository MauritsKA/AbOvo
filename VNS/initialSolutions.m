function [particles] = initialSolutions(nrJobs,nrParticles)
% creates random permutation of jobID's and assigns them to trucks 
particles = zeros(nrParticles,nrJobs);
for i = 1:nrParticles
    particles(i,:) = randperm(nrJobs);
end

end