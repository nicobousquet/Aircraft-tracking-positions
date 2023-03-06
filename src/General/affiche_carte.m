function [] = affiche_carte(REF_LON, REF_LAT)
% Plot trajectoire + logo avion
STYLES = {'-','--',':'};
STYLES_HEAD = {'x','o','<'};
COLORS = lines(6);
COLORS(4,:)=[];

figure(1);
hold on;

%Bdx
x = linspace(-1.3581,0.7128,1024);
y = linspace(44.4542,45.1683,1024);

[X,Y] = meshgrid(x,y(end:-1:1));
im = imread('fond.png');
image(x,y(end:-1:1),im);
plot(REF_LON,REF_LAT,'.r','MarkerSize',20);
text(REF_LON+0.05,REF_LAT,0,'Actual pos','color','b')
set(gca,'YDir','normal')
xlabel('Longitude en degres');
ylabel('Lattitude en degres');
zlim([0,4e4]);
% Bdx
xlim([-1.3581,0.7128]);
ylim([44.4542,45.1683]);
