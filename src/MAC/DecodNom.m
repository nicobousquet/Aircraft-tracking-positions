function [nom] = DecodNom(bn)
    
    nom = "";
    
    for i = 9:6:51
        car = bi2de(fliplr(bn(i:i+5)));
        alph = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        
        if car==0
            nom = nom;
        elseif car <= 26 && car>0
            nom = nom + alph(car);
        elseif car == 32
            nom = nom + " ";
        else
            nom = nom + string(car-48);
        end
    end
end

