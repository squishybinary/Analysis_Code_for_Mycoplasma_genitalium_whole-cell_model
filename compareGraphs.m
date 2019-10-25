% compareGraphs, overlays runGraphs output on a background of 200 wildtype simulations
% Combines the inital 4x2 subplot with a background figure, saving as a fig and PDF.
% Inspiration from this StackOverflow answer by user MrHappyAsthma: http://stackoverflow.com/questions/23476288/matlab-copy-two-fig-files-to-one-plot

% Author: Joshua Rees, joshua.rees@bristol.ac.uk
% Affiliation: BrisSynBio, Life Sciences, University of Bristol
% Last Updated: 13/08/2018

function compareGraphs(experiment, sim, backgroundfig)

%%% Declarations
backgroundfignumber = backgroundfig;
experimentname = experiment;
simname = sim;
underscore = '_';
figuresuffix = '.fig';
filenameimported = [experimentname underscore simname figuresuffix];
classification = 'classification';
filenameimported2 = [experimentname underscore simname underscore classification];

%%% Graph Manipulations
% Open matlab .fig files
fig1 = open(backgroundfignumber);
fig2 = open(filenameimported);

% Access all data in .fig files
ax1 = get(fig1, 'Children');
ax2 = get(fig2, 'Children');

% Remove the text subplot from the WildTypeBackground.fig
for i = 1 : numel(ax1) 
    ax1Children = get(ax1(i),'Children');
    text = findobj(fig1, 'Type', 'text');
    if ismember(ax1Children, text);
        delete(ax1Children);
    end
end

% Create a list of all the data in Simulation Figure, and a list of all the line data in Simulation Figure
% Compare the lists and copy only the plot lines and the text subplot from Simulation figure onto WildTypeBackground.fig, to create combined figure
for i = 1 : numel(ax2) 
    ax2Children = get(ax2(i),'Children');
    lines = findobj(fig2, 'Type', 'line');
    text = findobj(fig2, 'Type', 'text');
    if ismember(ax2Children, lines);
        copyobj(ax2Children, ax1(i));
    end
    if ismember(ax2Children, text);
        copyobj(ax2Children, ax1(i));
    end
end

% Close Simulation figure
close(fig2)

%%% Saving
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
saveas(gcf, filenameimported2, 'fig');
saveas(gcf, filenameimported2, 'pdf');

% Close Combined figure
close(fig1)
    
end

