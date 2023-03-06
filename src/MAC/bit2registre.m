function [registre] = bit2registre(b_received, registre, LATref, LONref)
    
    [d, error_flag] = decodeCRC(b_received);
    if error_flag==1
        registre.crcErrFlag = 1;
    else
        registre.crcErrFlag = 0;
    end
    registre.adresse = dec2hex(bi2de(fliplr(b_received(9:32))));
    registre.format = bi2de(fliplr(b_received(1:5))); %% 17 message type ADSB
    registre.type = bi2de(fliplr(b_received(33:37))); %% 1-4 FTC identif, 9-18 et 20-22 FTC vol pos
    
    if (registre.type >= 1 && registre.type <= 4) 
        
        registre.planeName = DecodNom(b_received(33:88));
        
    elseif (( 9 <= registre.type) && (registre.type <= 18)) || (( 20 <= registre.type) && (registre.type <= 22))
            
            registre.altitude = DecodAlt(b_received(41:52));
            registre.timeFlag = bi2de(fliplr(b_received(53)));
            registre.cprf = bi2de(fliplr(b_received(54)));
            registre.latitude = DecodLat(b_received(55:71), registre.cprf, LATref);
            registre.longitude = DecodLon(b_received(72:88), registre.cprf, LONref, registre.latitude);
        
    elseif (registre.type >= 5 && registre.type <= 8)
            registre.altitude = 0;
            registre.timeFlag = bi2de(fliplr(b_received(53)));
            registre.cprFlag = bi2de(fliplr(b_received(54)));
            registre.latitude = DecodLat(b_received(55:71), registre.cprFlag, LATref);
            registre.longitude = DecodLon(b_received(72:88), registre.cprFlag, LONref, registre.latitude);

    elseif (registre.type == 19)
            sub = bi2de(fliplr(b_received(38:40)));
            if (sub == 1 || sub == 3)
                registre.velocity = bi2de(fliplr(b_received(57:66)))-1;
            elseif (sub == 2 || sub == 4)
                registre.velocity = 4*(bi2de(fliplr(b_received(57:66)))-1);
            end
    end

end