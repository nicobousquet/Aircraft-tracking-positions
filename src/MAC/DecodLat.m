function [lat] = DecodLat(rlat,cpr, LATref)
    
    Nz = 15; %% nombre de latitudes géo
    Dlat = 360/(4*Nz-cpr);
    
    LAT = bi2de(fliplr(rlat));
    
    Nb = 17; %% nombre de bits constituant le registre de latitude
    j = floor(LATref/Dlat) + floor(1/2 + (LATref - Dlat*floor(LATref/Dlat))/Dlat - LAT/(2^Nb));
    
    lat = Dlat*(j + LAT/(2^Nb));
    
end

