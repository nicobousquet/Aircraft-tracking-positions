clear 
close all
clc

addpath('../PHY');

%% 
Ts = 1e-6; %temps symbole
fs = 1/Ts; %fréquence symbole
fe = 20e6; %fréquence d'échantillonage
Te = 1/fe; %période d'échantillonage
f_se= Ts/Te; %facteur de suréchantillonage

%% Chaine TX
Nb = 1e4;
b = randi([0 1], 1, Nb);

%% Modulation
s_l = modulatePPM(b, f_se); %on suréchantillone les bits en entrée

%% Calcul de la DSP
Nfft = 256;
[f, DSP] = Mon_Welch(s_l, Nfft, fe);
semilogy(f, DSP);
xlabel("f (Hz)");
ylabel("DSP");
title("DSP de s_l en fonction de la fréquence");

