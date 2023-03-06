function [liste_new_registre, corrVal] = process_buffer(cplxBuffer, REF_LON, REF_LAT,seuilDetection, Fse)
% -> decodePPM(packet,pulse0,pulse1) :              couche PHY
% -> bits2registre(bitPacketCRC,refLon,refLat) :    couche MAC
    [liste_new_registre, corrVal] = process_buffer_(cplxBuffer, REF_LON, REF_LAT,seuilDetection, Fse);
end

