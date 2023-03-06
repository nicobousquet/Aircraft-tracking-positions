function b_received = demodulatePPM(r_l, p, f_se)
    %prend le signal suréchantilloné, le filtre de mise en forme et le
    %facteur de suréchantillonage en entrée
    %retourne la séquence de bits reçus
    v_l = conv(abs(r_l), p);
    %% dans cette boucle, on sous_échantillonne
    r_m = [];
    for j=f_se:f_se:length(v_l)
        r_m = [r_m v_l(j)];
    end

    %% algorithme de décision
    b_received = [];
    for j=1:1:length(r_m)
        if r_m(j) <= 0
            b_received = [b_received 0];
        elseif r_m(j) > 0
            b_received = [b_received 1];
        end
    end