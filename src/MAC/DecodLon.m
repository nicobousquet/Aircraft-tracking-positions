function [lon] = DecodLon(rlon, cpr, LONref, lat)

        Nl = cprNL(lat);
        
        LON = bi2de(fliplr(rlon));
        
        if (Nl - cpr) > 0
            Dlon = 360/(Nl - cpr);
        else
            if (Nl - cpr) == 0
                Dlon = 360;
            end
        end
        
        Nb = 17;
        
        m = floor(LONref/Dlon) + floor(1/2 + (LONref - Dlon*floor(LONref/Dlon))/Dlon - LON/(2^Nb));
        
        lon = Dlon*(m + LON/(2^Nb));
        
end

