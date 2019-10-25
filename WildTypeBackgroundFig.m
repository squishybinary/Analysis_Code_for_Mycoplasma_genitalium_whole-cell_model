% WildTypeBackgroundFig, produces a background figire from existing WildType WholeCell simulation (runGraphs.m) figures to provide a comparison for Gene Knock Out Simulations.
% Inspiration from this StackOverflow answer by user MrHappyAsthma: http://stackoverflow.com/questions/23476288/matlab-copy-two-fig-files-to-one-plot

% Author: Joshua Rees, joshua.rees@bristol.ac.uk
% Affiliation: BrisSynBio, Life Sciences, University of Bristol
% Last Updated: 03/06/2017

function WildTypeBackgroundFig

%%% Graph Manipulations
% Assign all matlab .fig files in the current directory to the files variable
files = dir('*.fig');
% Open the first WildType Simulation figure, becoming the Base Figure
fig1 = open('WildType_1.fig');

for file = files'
    % Open each new matlab .fig file in order
	fig2 = open(file.name);
    
	% Access all data in .fig files
    ax1 = get(fig1, 'Children');
	ax2 = get(fig2, 'Children');
	
	% Create a list of all the data in New Figure, and a list of all the line data in New Figure
	% Compare the lists and copy all Line data from New Figure to Base Figure
	for i = 1 : numel(ax2) 
		ax2Children = get(ax2(i),'Children');
        lines = findobj(fig2, 'Type', 'line');
        if ismember(ax2Children, lines);
            copyobj(ax2Children, ax1(i));
        end
	end
	
	% Close New Figure
	close(fig2)
	
	% Keep Base Figure open for next New Figure
    hold on;
end

%%% Saving
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
saveas(gcf, 'WildTypeBackground', 'fig');
saveas(gcf, 'WildTypeBackground', 'pdf');

end
