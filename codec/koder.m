function [encodedStream, dictionary] = koder(C, S)
% C = [5 1 4 6 2 15 7 4 76 3 6 33 5 2 2 1 5 5 55 6 8 3 7 15 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 5 1 1 2 5 5 5 1 2]; % For easy debug
% S = [1 2 3; 2 4 3; 12 24 3;];
fprintf("Coder starting...\n")
    % Crafting the data stream
    S = reshape(S', [numel(S) 1])';
    C = [S C];
    [C, zeroMark]= zeroOut(C);
    C = [zeroMark C];
    C = [C(1:length(S)+1) zeroMark C(length(S)+2:end)];
    % crafting dictionary
    valueCount = scanInput(C);
    probabylityCount = convertToProbabylity(valueCount);
%     dictionary = rosetta(valueCount);
    huffdict = huffmandict(valueCount(1,:), probabylityCount);
    encodedStream = (huffmanenco(double(C), huffdict));
    saveFile(encodedStream)
    dictionary = huffdict;
%     [tmp1, tmp2] = dekoder(dictionary)
%   huffmanencoEXT(dictionary, C)
    % Out with the zeros!
    function [output, zeroMark] = zeroOut(C)
        mostCommonTracker = false(size(C));
        mostCommon = mode(C);
        zeroMark = createMark(C);
        mostCommonTracker(C == mostCommon) = true;
        C = string(C(~mostCommonTracker));
%         zeroTable = mostCommonTracker;
%         output = C(~zeroTable);
            zeroCnt = 0;
            zeroFound = false;
            startIndex = 1;
            zeroLinesDone = 0;
        for i = 1:size(mostCommonTracker,2)-1
            if(mostCommonTracker(i))
                i;
                zeroCnt = zeroCnt + 1;
                zeroFound = true;
            else
                if(zeroFound)
                    if startIndex == 1
                        C = [zeroCnt zeroMark C(startIndex:end)];
                        zeroLinesDone = zeroLinesDone + 1;
                    elseif startIndex == length(C)
                        C = [C(1:startIndex+1) zeroCnt zeroMark];
                    else
                        C = [C(1:startIndex + zeroLinesDone) zeroCnt zeroMark C(startIndex + zeroLinesDone + 1:end)];
                        zeroLinesDone = zeroLinesDone + 2;
                    end
                end
                startIndex = sum(~mostCommonTracker(1:i));
                zeroCnt = 0;
                zeroFound = false;
            end
        end
        zeroCnt
        if (zeroCnt ~= 0)
            C = [C zeroCnt zeroMark];
        end
        output = C;
    end
    %% Scan for probabylity of value appearing
    function itemCount = scanInput(C)
        C = double(C);
%     itemCount = zeros(2,size(unique(C),2));
    itemCount = [];
    newRegisteredItem = [C(1) 0]; % init
    itemCount = [itemCount rot90(newRegisteredItem, 3)];
    for stream = 1:size(C,2)
        registered = false;
        for item = 1:size(itemCount, 2)
            if itemCount(1,item) == C(stream)
                itemCount(2, item) = itemCount(2, item) + 1;
                registered = true;
            end
        end
        if registered == false
            newRegisteredItem = [C(stream) 1];
            itemCount = [itemCount rot90(newRegisteredItem, 3)];
        end
    end
    % Sort by biggest probabilities
    [~, sorted_vectors] = sort(itemCount(2,:), "descend");
    itemCount = itemCount(:, sorted_vectors);
    itemCount = double(itemCount);
    fprintf("Counting unique values complete...\n")
    end
    function converted = convertToProbabylity(itemCount)
        omega = sum(itemCount(2,:));
        converted = double(itemCount(2,:)) / omega;
    end
    function mark = createMark(C)
        mark = round(rand * pi * 1000 + 1);
        while (sum(mark == C(:)) > 0)
            mark = round(rand * pi);
        end
    end
    %% Making dictionary
    function rosettaStone = rosetta(itemCount)
        rosettaStone(2, :) = string(itemCount(1, :));
            divideAndConquer("", itemCount, 1)
            fprintf("Dictionary created...\n")
         %% Recurrent huffman grouping (huffman tree)
        function divideAndConquer(prefix, group, counter)
            if size(group, 2) == 1
                 codedIndex = rosettaStone(2,:) == string(group(1));
                    rosettaStone(1, codedIndex) = prefix;
            else
                omega = sum(group(2,:));
                grouping = true;
                equalizer = 1;
                while (grouping)
                    if (sum(group(2, 1:equalizer)) >= omega / 2 )
                        grouping = false;
                    else
                        equalizer = equalizer + 1;
                    end
                end
                if (equalizer == 1)
                    codedIndex = rosettaStone(2,:) == string(group(1));
                    rosettaStone(1, codedIndex) = [prefix + '0'];
                else
                    divideAndConquer([prefix + '0'], group(:, 1:equalizer), counter + 1)
                end
                divideAndConquer([prefix + '1'], group(:, equalizer+1:end), counter + 1)
            end
        end
    end
%     function huffmanencoEXT(dictionary, stream)
%         dict(2,:) = { dictionary(2,:) }
%     end
    function saveFile(encoded)
        fileID=fopen("compressedIMG.jpd", "W");
        fwrite(fileID, encoded, 'ubit1');
        fclose(fileID);
        fprintf("Writing compressed image complete.\n")
    end
    %% Encode stream
%     function encodedStream = encode(dictionary, stream)
%         encodedStream = nan(size(stream));
%         translationCounter = false(size(stream));
%         for value = 1:size(dictionary,2)
%             value % debug
%             encodedStream(string(stream(~translationCounter)) == dictionary(2,value)) = dictionary(1,value); 
%             translationCounter(string(stream) == dictionary(2,value)) = true; % To speed up calculations we track 
%             % indices already translated so we can skip them
%         end
%     end
end