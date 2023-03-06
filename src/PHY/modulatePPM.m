function s_l = modulatePPM(b, f_se)
    %prends la séquence de bits envoyés et le facteur de suréchantillonage en entrée
    %retourne le signal suréchantilloné
    s_l = zeros(1, f_se*length(b)); %bits suréchantillonés
    for i=1:1:length(b)
        if b(i) == 1 %si le bit vaut 1
            s_l((i-1)*f_se+ 1:(i-1)*f_se+f_se/2) = 1;
        elseif b(i) == 0 %si le bit vaut 0
            s_l((i-1)*f_se+f_se/2 + 1:i*f_se) = 1;
        end
    end
end