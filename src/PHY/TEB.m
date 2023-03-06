function TEB = TEB(Eb_N0, variance_nl, Nb, f_se, p, Te)
    %prends le rapport signa/bruit, la variance du bruit, le nombre de bits
    %par salve, le facteur de suréchantillonage et le filtre de mise en
    %forme en entrée
    %retourne le taux d'erreur binaire
    TEB = zeros(1, length(Eb_N0));
    threshold = 100; %seuil nombre d'erreurs
    for i=1:1:length(Eb_N0) %pour chaque rapport signal/bruit
        error_cnt = 0; %nombre d'erreurs total
        bit_cnt = 0; %nombre de bits total émis
        while error_cnt<threshold %tant que le nombre d'erreurs trouvées est inférieur au seuil
            b = randi([0 1], 1, Nb); %on génère nos bits
            s_l = modulatePPM(b,f_se); %on suréchantillone le signal b
            r_l = synchronization(s_l, f_se, Te, variance_nl(i));
            b_received = demodulatePPM(r_l, p, f_se); %bit reçus
            for j=1:1:min(length(b),length(b_received))
                if b(j) ~= b_received(j) %si le bit en entrée est différent du bit en sortie
                    error_cnt = error_cnt+1;
                end
            end
            bit_cnt = bit_cnt + Nb;
            disp([num2str(error_cnt),'/', num2str(threshold)]);
        end
        TEB(i) = error_cnt/bit_cnt; %taux d'erreur binaire
    end
end