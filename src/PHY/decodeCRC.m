function [d, error_flag] = decodeCRC(b)
    det = comm.CRCDetector([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]); %polynême détecteur
    [d, error_flag] = det(b'); %on vérifie le CRC des bits reçus
    d = d';
end