function [alt] = DecodAlt(r)
    
    r =  [r(1:7) r(9:12)];
    ra = bi2de(fliplr(r));
    alt = 25*ra - 1000;
    
end

