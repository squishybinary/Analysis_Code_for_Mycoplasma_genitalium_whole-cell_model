% runGraphs, produces initial analysis of WholeCell simulations
% Creates a 4x2 subplot showing the initial analysis of the Whole Cell simulation, saving as a fig and PDF.

% Author: Joshua Rees, joshua.rees@bristol.ac.uk
% Affiliation: BrisSynBio, Life Sciences, University of Bristol
% Last Updated: 2018-10-30

function runGraphs(experiment, sim, umbrella, customendtimename)

%%% Declarations
time = [];
growth = [];
cytosolprotein = [];
rna = [];
chromosome = [];
septum = [];
mass = [];
terminalorganelleprotein = [];
umbrellaname = umbrella;
experimentname = experiment;
simname = sim;
daterun = date;
endtimename = customendtimename;

%%% Sorting Data
% Sorting Dir code from this thread: https://uk.mathworks.com/matlabcentral/newsreader/view_thread/270611
% BlueGem uses = d(dx(1)).name; / e(ex(1)).name;
% Local runs uses = d(dx(end)).name; / e(ex(end)).name;

% Find all mat files
d = dir('*.mat');
% Sort and pick the 'last' file 
[dx,dx] = sort([d.datenum],'descend');
summaryfilemaybe = d(dx(1)).name;

% Find all state files
e = dir('state-*.mat');
% Sort and pick the 'last' file 
[ex,ex] = sort([e.datenum],'descend');
laststatefile = e(ex(1)).name;
% Edit the state file name to produce a number (total states in the simulation)
laststatenum = laststatefile(7:9);
laststatenumb = regexprep(laststatenum,'[\. m]',''); %replaces '.', 'm', ' '.
laststatenumber = str2num(laststatenumb);

%%% Loading Data
for i=1:laststatenumber
        data = load(strcat('state-',num2str(i),'.mat'));
        time = [time; (((squeeze(data.Time.values))/60)/60)];
       
		growth = [growth; squeeze(data.MetabolicReaction.growth(1,1,:))];
		cytosolprotein = [cytosolprotein; squeeze(data.Mass.proteinWt(1,1,:))];
		rna = [rna; squeeze(data.Mass.rnaWt(1,1,:))];
        chromosome = [chromosome; squeeze(data.Chromosome.ploidy)];
        septum = [septum; squeeze(data.Geometry.pinchedDiameter)];
    
		mass = [mass; squeeze(data.Mass.cell(1,1,:))];
        %terminalorganelleprotein = [terminalorganelleprotein; squeeze(data.Mass.proteinWt(1,5,:))];
end

%%% SubPlotting
% Growth
subplot(2, 4, 1);
%plot(time, growth,'k'); %Black lines for WildTypeBackground
plot(time, growth,'r'); %Red lines for KOs / Sims 
xlabel('Time (h)'); 
%axis([0 14 2e-05 5e-05]);
axis([0 14 2e-05 inf]);
title('Growth','FontSize',12);
 
% Cytosol Protein
subplot(2, 4, 2);
%plot(time, cytosolprotein,'k');
plot(time, cytosolprotein,'r');
xlabel('Time (h)');
%axis([0 14 0e-15 5e-15]);
axis([0 14 0e-15 inf]);
title('Cytosol Protein','FontSize',12); %Protein in Cytosol

% RNA
subplot(2, 4, 3);
%plot(time, rna,'k');
plot(time, rna,'r');
xlabel('Time (h)');
%axis([0 14 0e-16 4e-16]);
axis([0 14 0e-16 inf]);
title('RNA','FontSize',12);

% Chromosome
subplot(2, 4, 4);
%plot(time, chromosome,'k');
plot(time, chromosome,'r');
xlabel('Time (h)');
%axis([0 14 0 2]);
axis([0 14 0 2.1]);
title('Chromosome','FontSize',12);

% Septum / Cell Diameter Change
subplot(2, 4, 5);
%plot(time, septum,'k');
plot(time, septum,'r');
xlabel('Time (h)');
axis([0 14 0 3e-07]);
title('Cell Diameter Change','FontSize',12);

% Mass
subplot(2, 4, 6);
%plot(time, mass,'k');
plot(time, mass,'r');
xlabel('Time (h)');
%axis([0 14 1e-14 3e-14]);
axis([0 14 1e-14 inf]);
title('Mass','FontSize',12);

% Terminal Organelle
%subplot(2, 4, 7);
%plot(time, terminalorganelleprotein,'k');
%plot(time, terminalorganelleprotein,'r');
%xlabel('Time (h)');
%axis([0 14 2.5e-17 5.5e-17]);
%title('Terminal Organelle Protein','FontSize',12); %Protein in Terminal Organelle

% Prediction and N of Deletions and Gene Codes
maxtime = time(end,:);
celldiameterstartvalue = septum(1,:);
celldiameterfinalvalue = septum(end,:);
startchromosome = chromosome(1,:);
endchromosome = chromosome(end,:);
startgrowth = growth(1,:);
endgrowth = growth(end,:);
startprotein = cytosolprotein(1,:);
endprotein = cytosolprotein(end,:);
startrna = rna(1,:);
endrna = rna(end,:);

if maxtime > 5 & maxtime < 13.88
	predictionprefix = 'Divided';
	predictionsuffix = 'Non Essential ';
elseif maxtime < 5
	predictionprefix = 'NoDivision';
    predictionsuffix = 'DNA/RNA/Protein/Metabolic ';
elseif maxtime >= 13.88
	predictionprefix = 'NoDivision';
    predictionsuffix = 'DNA/RNA/Protein/Metabolic ';
end	

if maxtime >= 13.89 &  celldiameterfinalvalue < celldiameterstartvalue
	predictionsuffix = 'Slow Growing';
elseif maxtime >= 13.89 & celldiameterfinalvalue == celldiameterstartvalue & endchromosome == 2
	predictionsuffix = 'Septum Mutant';
end

% predictionprefix and suffix flipped on next line - to make regex capture comparison easier (Divided vs NoDivision)
prediction = [predictionsuffix predictionprefix];

koprefix = '/home/jr0904/BlueGem/KOLists/';
kosuffix = '_ko.list';
kolist = [koprefix umbrella kosuffix];
lineofko = str2num(simname);
linestoignore = lineofko - 1;

fid = fopen(kolist);
if fid ~= -1
  for i=1:linestoignore
    fgetl ( fid );
  end
  koLine = fgetl ( fid );
  koLine = regexprep(koLine,'''','');
  fclose ( fid );
end

if length(koLine) == 0
	nofdeletions = 0;
	genesdeleted = 'None, WildType';
elseif length(koLine) == 7
	nofdeletions = 1;
	genesdeleted = regexprep(koLine,'[MG_,]','');
elseif length(koLine) > 7
	nofdeletions = (((length(koLine) - 7)/8)+1);
	genesdeleted = regexprep(koLine,'[MG_]','');
    genesdeleted = genesdeleted(1:25);
else 
	nofdeletions = 0;
	genesdeleted = 'File not Found';
end	
ax = subplot(2, 4, 7);
nofdeletions = num2str(nofdeletions);
str = sprintf(['Divided= %s\nPredic= %s\nN of Deletions = %s\nDeleted = %s']...
    ,predictionprefix,predictionsuffix,nofdeletions,genesdeleted);
text(0.1,0.1,str);
set (ax, 'visible', 'off');

% Information Text Box
% Extract seed number from options.mat if it exists
options_seed = 0;
currentfolder = pwd;
if exist(fullfile(currentfolder, 'options.mat'), 'file')
   seedretrieval = load('options.mat');
   options_seed = seedretrieval.seed;
end

% Sub Plot contains Seed Number, Time, Summary File presence, Last State File, Experiment Name, Sim Number, and Date Run
ax = subplot(2, 4, 8);
str = sprintf(['Experiment Name = %s\nGroup Name = %s\nSimulation Number = %s\nSeed = %d\nTime Running = %4.2f h\nGrowth= %e / %e\nProtein= %e / %e\nRNA= %e / %e\nLast File Created = %s\nLast State File = %s\nDate Created = %s']...
    ,umbrellaname,experimentname,simname,options_seed,maxtime,startgrowth,endgrowth,startprotein,endprotein,startrna,endrna,summaryfilemaybe,laststatefile,daterun);
text(0.1,0.1,str);
set (ax, 'visible', 'off');

%%% Saving
% fig has to be saved first on BlueGem for some reason. Do not switch around.
underscore = '_';
filenameimported = [experimentname underscore simname];
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition', [0 0 1 1]);
saveas(gcf, filenameimported, 'fig');
saveas(gcf, filenameimported, 'pdf');

%%% Create endtimes.txt
endtimesprefix = '../../';
endtimessuffix = 'ndtimes.txt';
lowercaseE = 'e'
simint = str2num(simname);
%maxtimeint = str2num(maxtime);

if endprotein > startprotein
	outcomeone = 'UP';
elseif endprotein < startprotein
	outcomeone = 'DOWN'
else 
	outcomeone = 'Unknown';
end	

if endrna > startrna
	outcometwo = ' UP ';
elseif endrna < startrna
	outcometwo = ' DOWN '
else 
	outcometwo = ' Unknown ';
end	

protein = [startprotein endprotein];
rna = [startrna endrna];
outcomes = [outcomeone outcometwo];
numbers = [simint maxtime protein rna];
letters = [outcomes prediction];

filename = [endtimesprefix experimentname underscore simname underscore lowercaseE endtimessuffix];
filename2 = [endtimesprefix endtimename endtimessuffix];

dlmwrite(filename,numbers,'-append','delimiter','\t','precision',4);
dlmwrite(filename,letters,'-append','delimiter','');
dlmwrite(filename2,numbers,'-append','delimiter','\t','precision',4);
dlmwrite(filename2,letters,'-append','delimiter','');

%%% Archived
% > DNA switched for Chromsome
% dna = []; 
% dna = [dna; squeeze(data.Mass.dnaWt(1,1,:))];
% subplot(2, 4, 4);
% plot(time, dna,'r');
% xlabel('Time (h)');
% axis([0 12 5e-16 13e-16]);
% title('DNA','FontSize',12);

% > diary_seed = options_seed
%diaryretrieval = textread('diary.out', '%s','delimiter', '\n');
%find line num from test run of MGGRunner
%diary_seed= diaryretrieval{LineNum};

end