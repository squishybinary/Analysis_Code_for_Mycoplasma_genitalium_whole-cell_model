% MGG(Minimal Genome Group)Runner, a sub class of Karr's SimulationRunner Class

% Author: Joshua Rees, joshua.rees@bristol.ac.uk
% Affiliation: BrisSynBio, Life Sciences, University of Bristol
% Last Updated: 03/06/2017

% Create variable in Slurm Script, which passes the array/sim number through
% SeedInc=${SLURM_ARRAY_TASK_ID} 
% Add to runSimulation(..,'seedIncrement','${SeedInc}',..)

% One Second is approx a 175000 change in now() value, on 01/06/2017
% Seed size: 9 digits + 8 digits for 100s sims OR 9 digits for 1000s sims
% Bug: 11th sim producing 2 seeds, 101th sim producing 3 seeds
% Fix: str2num. Array/sim number passed as string, causing error, converted back to num.

classdef MGGRunner < edu.stanford.covert.cell.sim.runners.SimulationRunner
	methods
		function this = MGGRunner(varargin)
			this = this@edu.stanford.covert.cell.sim.runners.SimulationRunner(varargin{:});
		end
	end

    properties
		seedIncrement = 0;
		koList=[];
    end
    
	methods (Access = protected)		
		function modifyNetworkParameters(this, sim)
			this.seedIncrement = str2num(this.seedIncrement);
			% Print Array/Sim Number to Diary
			this.seedIncrement
			% Create new seed with Arrays seperated by ~1 second gaps
			seed = round(1e6 * mod(now(), 1e3) + (this.seedIncrement+(this.seedIncrement*174999))); 
			% Override old seed
			this.seed = seed;
			% Print seed to Diary
			seed
			
			% Check if koList was passed by Slurm Script. 1 = is empty, 0 = is not empty. 
			% If 1 then skip, either WildType sim or koList unreachable.
			if isempty(this.koList) == 0
				% Override old (empty) koList
				koList=this.koList;
				% Print koList to Diary
				koList
				% Apply koList to Simulation
				sim.applyOptions('geneticKnockouts', koList);
			end
		end
	end
	
end
