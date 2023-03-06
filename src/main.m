clear;
close all;
clc;

addpath('./PHY');
addpath('./MAC');
addpath('../data');
addpath('./General');
load('adsb_msgs.mat');

%% Tache 1 ----------------------------------------------------------------
Ts = 1e-6; %temps symbole
fs = 1/Ts; %fréquence symbole
fe = 20e6; %fréquence d'échantillonage
Te = 1/fe; %période d'échantillonage
f_se= Ts/Te; %facteur de suréchantillonage

%% Chaine TX
Nb = 10000;
b = randi([0 1], 1, Nb);
%% Génération CRC
b = encodeCRC(b);
%% Modulation
s_l = modulatePPM(b, f_se); %on suréchantillone les bits en entrée
%% Test modulate
figure;
%t = Te:Te:Ts*length(b); %échelle des temps
%plot(t, s_l);
%xlabel('Temps (s)');
%ylabel('s_l');
%title('Signal suréchantillonné');
%grid on;
%ylim([-0.15, 1.15])
%% Calcul de la DSP
figure;
Nfft = 2^15;
[f, DSP] = Mon_Welch(s_l, Nfft, Nfft/32, -fe/2, fe/2);
semilogy(f, DSP);
xlabel("f (Hz)");
ylabel("DSP");
title("DSP de s_l en fonction de la fréquence");
hold on;
f = -fe/2:fe/(2^13):fe/2;
DSP_theorique = @(f) 0.25*dirac(f) + (((Ts^3)*((pi*f).^2))/16).*((sinc((Ts/2)*f)).^4);
semilogy(f, fe*DSP_theorique(f));
%%
f = @(t) (t>=0 && t<=Ts/2)*-0.5 + (t>Ts/2 && t<=Ts)*0.5; %filtre de mise en forme
p = arrayfun(f, Te:Te:Ts);

%% chaine RX
b_received = demodulatePPM(s_l, p, f_se);
%% Vérification CRC
[outdata, error] = decodeCRC(b_received); %on vérifie le CRC des bits reçus
b_received = outdata';
if error
    disp("Il y a des erreurs dans le message reçu");
else
    disp("Il n'y a pas d'erreur dans le message reçu");
end
%% Implémentation Couche Mac
% Coordonnees de reference (endroit de l'antenne)
LONref = -0.606629; % Longitude de l'ENSEIRB-Matmeca
LATref = 44.806884; % Latitude de l'ENSEIRB-Matmeca
affiche_carte(LONref, LATref);
listOfPlanes = [];
liste_new_registre = [];
liste_corrVal = [];
n = 1;
DISPLAY_MASK = '| %12.12s | %10.10s | %6.6s | %3.3s | %6.6s | %3.3s | %8.8s | %11.11s | %4.4s | %12.12s | %12.12s | %3.3s |\n'; % Format pour l'affichage
CHAR_LINE = '+--------------+------------+--------+-----+--------+-----+----------+-------------+------+--------------+--------------+-----+\n'; % Lignes
fprintf(DISPLAY_MASK,'     n      ',' t (in s) ','Corr.', 'DF', '  AA  ','FTC','   CS   ','ALT (in ft)','CPRF','LON (in deg)','LAT (in deg)','CRC');
fprintf(CHAR_LINE);
for i=1:1:length(adsb_msgs(1, :))
    b = adsb_msgs(:, i)';
    b_received = b;
    registre = struct('adresse',[],'format',[],'type',[],'planeName',[],'altitude',[],'timeFlag',[],'cprf',[],'latitude',[],'longitude',[], 'crcErrFlag', [], 'velocity',[]);
    registre = bit2registre(b_received, registre, LATref, LONref);
    liste_new_registre = [liste_new_registre {registre}];
    liste_corrVal = [liste_corrVal 0];
end
listOfPlanes = update_liste_avion(listOfPlanes, liste_new_registre, DISPLAY_MASK, fe, n, liste_corrVal); 
for plane_ = listOfPlanes
        plot(plane_);
end
%% calcul taux d'erreur binaire théorique
Eb_N0_dB = 0:1:10; %Eb/N0 en dB
Eb_N0 = 10.^(Eb_N0_dB/10);
P_b = 0.5*erfc(sqrt(Eb_N0)); %Probabilité d'erreur binaire théorique

%% calcul taux d'erreur binaire expérimental
variance_a = 1; %variance 
M = 2; %nombre de symboles
E_p = sum(p.*p); %énergie du filtre
variance_nl = (variance_a*E_p)./(2*log2(M)*Eb_N0); %variance du bruit

Nb = 112; %nombre de bits émis
TEB = TEB(Eb_N0, variance_nl, Nb, f_se, p, Te); %liste des taux d'erreurs binaires

%plot du TEB théorique et expérimental
figure;
semilogy(Eb_N0_dB, P_b, Eb_N0_dB, TEB);
xlabel("(E_b/N_0) (dB)");
ylabel("P_b");
title("TEB en fontion du rapport signal sur bruit");
legend("Pb", "TEB exp");

%% Détection des avions dans le buffer (tâche 8)
disp(" ");
disp("Tâche 8");
disp(" ");
load("../data/buffers.mat");
Ts = 1e-6; %temps symbole
fs = 1/Ts; %fréquence symbole
fe = 4e6; %fréquence d'échantillonage
Te = 1/fe; %période d'échantillonage
f_se= Ts/Te; %facteur de suréchantillonage
f = @(t) (t>=0 && t<=Ts/2)*-0.5 + (t>Ts/2 && t<=Ts)*0.5; %filtre de mise en forme
p = arrayfun(f, Te:Te:Ts);
trames_identifiees = [];
liste_corrVal = [];

for indice=1:1:length(buffers(1,:))
    disp([num2str(indice),'/', num2str(length(buffers(1,:)))]);
    y_l = buffers(:, indice);
    r_l = abs(y_l).^2;
    p1 = ones(1, f_se/2);
    p2 = zeros(1, f_se/2);
    s_p = [p1 p2 p1 p2 p2 p2 p2 p1 p2 p1 p2 p2 p2 p2 p2 p2]; %on crée le préambule
    s_p_bis = [zeros(1, length(r_l)-length(s_p)) s_p]; %on met s_p à la même taille que r_l pour la corrélation
    intercorr = xcorr(r_l, s_p_bis);
    intercorr = intercorr(length(s_p):(length(r_l)));
    porte = ones(1, length(s_p));
    liste = conv(abs(r_l').^2, porte, 'valid');

    denom = sqrt(sum(abs(s_p).^2)).*sqrt(liste);
    rho = intercorr'./(denom);
    index = find(rho>0.75);
%     dans cette boucle, on filtre les pics consécutifs pour ne garder que
%     le maximum local
    index_bis = [];
    i = 1;
    while i<=length(index)
        j=0;
        while(i+j+1<=length(index))
            if(index(i+j+1)-index(i))<480
                j=j+1;
            else
                break;
            end
        end
        sub_array = index(i:i+j);
        [M, I] = max(rho(sub_array));
        index_bis = [index_bis sub_array(I)];
        i = i+j+1;
    end
    index = index_bis;
    for i=1:1:length(index)
        for k=-3:1:3
            if index(i)+119*4+k<=length(y_l)
                trame = demodulatePPM(y_l(index(i)+f_se*8+k:index(i)+119*f_se+k)', p, f_se);
                [d, error_flag] = decodeCRC(trame);
                if error_flag==0
                    liste_corrVal = [liste_corrVal rho(index(i))];
                    trames_identifiees = [trames_identifiees trame']; 
                end
            end
        end
    end
end

% affichage des avions
LONref = -0.606629; % Longitude de l'ENSEIRB-Matmeca
LATref = 44.806884; % Latitude de l'ENSEIRB-Matmeca
listOfPlanes = [];
liste_new_registre = [];
n = 1;
DISPLAY_MASK = '| %12.12s | %10.10s | %6.6s | %3.3s | %6.6s | %3.3s | %8.8s | %11.11s | %4.4s | %12.12s | %12.12s | %3.3s |\n'; % Format pour l'affichage
CHAR_LINE = '+--------------+------------+--------+-----+--------+-----+----------+-------------+------+--------------+--------------+-----+\n'; % Lignes
fprintf(DISPLAY_MASK,'     n      ',' t (in s) ','Corr.', 'DF', '  AA  ','FTC','   CS   ','ALT (in ft)','CPRF','LON (in deg)','LAT (in deg)','CRC');
fprintf(CHAR_LINE);
affiche_carte(LONref, LATref);
for i=1:1:length(trames_identifiees(1, :))
    b_received = trames_identifiees(:, i)';
    registre = struct('adresse',[],'format',[],'type',[],'planeName',[],'altitude',[],'timeFlag',[],'cprf',[],'latitude',[],'longitude',[], 'crcErrFlag', [], 'velocity', []);
    registre = bit2registre(b_received, registre, LATref, LONref);
    liste_new_registre = [liste_new_registre {registre}];
end
listOfPlanes = update_liste_avion(listOfPlanes, liste_new_registre, DISPLAY_MASK, fe, n, liste_corrVal); 

for plane_ = listOfPlanes
        plot(plane_);
end


