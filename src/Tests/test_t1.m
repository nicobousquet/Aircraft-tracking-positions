clear;
close all;
clc;

addpath('../PHY');
%%
Ts = 1e-6; %temps symbole
fs = 1/Ts;
fe = 20e6; %fréquence d'échantillonnage
Te = 1/fe; %période d'échantillonnage
f_se= Ts/Te; %facteur de suréchantillonnage

%% chaine TX
b = [1 1 0 1 1 0 0 1];
s_l = modulatePPM(b, f_se);%on suréchantillonne les bits en entrée

%% on plot s_l
figure;
t = Te:Te:Ts*length(b); %échelle des temps
plot(t, s_l);
xlabel('Temps (s)');
ylabel('s_l');
grid on;
ylim([-0.15, 1.15])
%% on définit le filtre de mise en forme
f = @(t) (t>=0 && t<=Ts/2)*-0.5 + (t>Ts/2 && t<=Ts)*0.5; 
p = arrayfun(f, Te:Te:Ts);
%% chaine RX
b_received = demodulatePPM(s_l, p, f_se);
%% test de demodulate
nb_erreur = sum(b ~= b_received);
disp(['Nombre d''erreurs observees : ', num2str(nb_erreur)])