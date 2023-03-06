function [f, DSP] = Mon_Welch(s_l, Nfft, sample_length, fmin, fmax)
%prends s_l, le signal suréchantillonné, Nfft,le nombre de points pour
%la fft, et fe, la fréquence d'échantillonnage
%retourne DSP, la densité spectrale du puissance de s_l et f, l'axe des
%fréquence
D = ceil((sample_length)/3); %taux de chevauchement
number_of_samples = ceil(length(s_l)/D); %nombre de segments de s_l
sample_matrix = zeros(number_of_samples, Nfft);
DSP = 0;

for i=1:1:number_of_samples
    if ((i-1)*D+sample_length)<=length(s_l)
        sample_matrix(i,:) = fftshift(fft(s_l(1+(i-1)*D:(i-1)*D+sample_length), Nfft)); %on remplit chaque ligne de la matrice avec la fft de chaque segment
        DSP = DSP+(1/(sample_length*number_of_samples))*(abs(sample_matrix(i,:)).*abs(sample_matrix(i,:))); %on somme les DSP
    else
        sample_matrix(i:number_of_samples,:) = []; %on vire les dernières lignes de 0 de la matrice
        break
    end
end

f = fmin:(fmax-fmin)/(Nfft-1):fmax; %axe des abcisses
end