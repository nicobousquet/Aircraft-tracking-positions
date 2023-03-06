function b = encodeCRC(b)
    gen = comm.CRCGenerator([1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1]); %polynôme générateur
    encoded = gen(b'); %on génère le signal avec le CRC
    b = encoded';
end