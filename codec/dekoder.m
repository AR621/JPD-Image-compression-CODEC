function [C, S] = dekoder(dictionary)
    fprintf("Starting decompression...\n")
    fileID=fopen("compressedIMG.jpd");
    encodedStream = fread(fileID, 'ubit1');
    fclose(fileID);
    decoded = huffmandeco(encodedStream, dictionary);
    
    zeroMark = decoded(1); decoded(1) = [];
    % Retrieving S matrix
    C=[];
    S=[];
    j = 1;
    while (sum(decoded(1:3) == zeroMark) == 0) 
        S(j,:) = decoded(1:3);
        decoded(1:3) = [];
        j = j + 1;
    end; decoded(1) = []; % cleaning up so we are left with C vector
    % De-zeroing data stream
    for entry = 1:length(decoded)
        adendum = [];
        if decoded(entry) == zeroMark
            for zero = 1:decoded(entry-1)
                adendum = [adendum 0];
            end
            if entry == length(decoded)
                C = [C 0];
            end
            C(end) = []; % cleanup
%             decoded(entry-1:entry) = [];
        else
            adendum = decoded(entry);
        end
        C = [C adendum];
    end
end