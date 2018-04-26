function [y x] = organize_data_new(timeVector, triggersVector,...
    titlesVector, sortedIndices, defaultSubName)

    
    dataTable = {};
    subIdIndex = 1;
    timeIndex = 2;
    letterIndex = 3;
    rtIndex = 4;
    responseTypeIndex = 5;
    conditionIndex = 6;
    isPracticeIndex = 7;
    nIndex = 8;
    ringPassedStatusIndex = 9;
    isSuccessIndex = 10;
    ringSizeIndex = 11;
    blockNumberIndex = 12; 
    speedIndex = 13;
    difficultLevelIndex = 14;
    isBaselineIndex = 15;
    blockTypeIndex = 16;
    
    
    currentRowIndex = 1;
    currentNbackRow = -1;
    currentRingRow = -1;
    global titles;
    global blockTimes;
    global subId;
    global startTime;
    global startMagnetTime;
    global endInstructions;
    global startInstructions;
    global endFixation;
    global startFixation;
    global condition;
    global level;
    global ringSize;
    global isPractice;
    global lastLetterTime;
    global lastLetter;
    global blockNumber;
    global speed;
    global difficultLevel;
    global blockNumberInt;
    global blockType;
    global isBaseline;
    global endBlockTime;
    global movementsAmount;
    global pitchDirectionChanges;
    global yawDirectionChanges;
    global lastPitchChangeSign;
    global lastYawChangeSign;
    global lastPitchValue;
    global lastYawValue;
    
    pitchDirectionChanges = 0;
    yawDirectionChanges = 0;
    lastPitchChangeSign = 0;
    lastYawChangeSign = 0;
    titles = titlesVector;
    lastLetter = "";
    blockNumberInt = -1;
    blockTimes = {};
    for sortedIndex = 1:numel(sortedIndices)
        n = sortedIndices(sortedIndex);
        trigger = triggersVector(1,n);
        yawOrPitch = checkIfYawOrPitch(trigger, n);
        if yawOrPitch == 0
            trigger = trigger{1};
            isJoystickMovement(trigger, n);
            isStartStressEvaluation(trigger, n, timeVector);
            isStartInstructions(trigger, n, timeVector);
            isEndInstructions(trigger, n, timeVector);
            isStartFixation(trigger, n, timeVector);
            isEndFixation(trigger, n, timeVector);
            checkIfStartTrigger(trigger, n, timeVector, defaultSubName);
            checkIfEndTrigger(trigger, n, timeVector);

            checkIfLetter(trigger, n, timeVector);

            nBackResponse = isNbackResponse(trigger, n);
            if nBackResponse ~= "None"
                newRowsIndices = progressRowsNumbersIfNeeded(currentRowIndex, currentNbackRow,...
                    currentRingRow, "nBack");
                currentRowIndex = newRowsIndices(1);
                currentNbackRow = newRowsIndices(2);
                currentRingRow = newRowsIndices(3);

                dataTable{currentNbackRow,subIdIndex} = char(subId);
                dataTable{currentNbackRow,nIndex} = char(level);
                dataTable{currentNbackRow,conditionIndex} = char(condition);
                dataTable{currentNbackRow,responseTypeIndex} = char(nBackResponse);

                dataTable{currentNbackRow,timeIndex} = timeVector(n) - startTime;
                dataTable{currentNbackRow,letterIndex} = lastLetter{1,1};
                dataTable{currentNbackRow,ringSizeIndex} = char(ringSize);
                dataTable{currentNbackRow,blockNumberIndex} = char(blockNumber);
                dataTable{currentNbackRow,speedIndex} = char(speed);
                dataTable{currentNbackRow,isPracticeIndex} = char(isPractice);
                dataTable{currentNbackRow,blockTypeIndex} = char(blockType);
                dataTable{currentNbackRow,difficultLevelIndex} = difficultLevel;
                dataTable{currentNbackRow,isBaselineIndex} = char(isBaseline);

                if string(nBackResponse) == "HIT"
                    dataTable{currentNbackRow,rtIndex} = timeVector(n) - startTime - lastLetterTime;
                end
                if string(nBackResponse) == "HIT" || string(nBackResponse) == "CorrectRejection"
                    dataTable{currentNbackRow,isSuccessIndex} = 1;
                else
                    dataTable{currentNbackRow,isSuccessIndex} = 0;
                end
            end
            ringResponse = isRingResponse(trigger, n);
            ringResponseSize = size(ringResponse);
            if ringResponseSize(1) > 0
                newRowsIndices = progressRowsNumbersIfNeeded(currentRowIndex, currentNbackRow,...
                    currentRingRow, "ring");
                currentRowIndex = newRowsIndices(1);
                currentNbackRow = newRowsIndices(2);
                currentRingRow = newRowsIndices(3);
                status = ringResponse{1,1};
                isSuccess = 0;
                if status == '1'
                    isSuccess = 1;
                end
                dataTable{currentRingRow,subIdIndex} = char(subId);
                dataTable{currentRingRow,conditionIndex} = char(condition);
                dataTable{currentRingRow,ringPassedStatusIndex} = char(status);

                dataTable{currentRingRow,ringSizeIndex} = char(ringSize);
                dataTable{currentRingRow,timeIndex} = timeVector(n) - startTime;
                dataTable{currentRingRow,letterIndex} = char('None');
                dataTable{currentRingRow,nIndex} = char(level);
                dataTable{currentRingRow,blockNumberIndex} = char(blockNumber);
                dataTable{currentRingRow,blockTypeIndex} = char(blockType);
                dataTable{currentRingRow,speedIndex} = char(speed);
                dataTable{currentRingRow,isPracticeIndex} = char(isPractice);
                dataTable{currentRingRow,difficultLevelIndex} = difficultLevel;
                dataTable{currentRingRow,responseTypeIndex} = char('None');
                dataTable{currentRingRow,isBaselineIndex} = char(isBaseline);
            end
        end
    end
    
    y = dataTable;
    x = blockTimes;

    
end

function isStartStressEvaluation(trigger, n, timeVector)
    global blockNumberInt;
    global startMagnetTime;
    global endBlockTime;
    global titles;
    title = titles(n);
    if strcmp(title{1}, 'taskMarkers')
        startStress = strfind(trigger, 'eval_start_1_stress');
        appearancenStartStress = size(startStress{1,1});
        if appearancenStartStress(1) > 0
           if blockNumberInt == -1 || blockNumberInt == 14 
               startMagnetTime = timeVector(n);
               endBlockTime = startMagnetTime;
           end
        end
    end
    
end

function result = checkIfLetter(trigger, n, timeVector)
     global lastLetter
     global lastLetterTime
     global startTime
     global titles;
     result = '';
     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         letter = strfind(trigger, 'letter');
         appearance = size(letter{1,1});
         if appearance(1) ~= 0
             result = extractAfter(trigger, "letter_letter_");
             lastLetter = result;
             lastLetterTime = timeVector(n) - startTime;
         end
     end
end

function result = isRingResponse(trigger, n)
     global titles;
     result = {};
     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         ring = strfind(trigger, 'ring_passed');
         appearanceRing = size(ring{1,1});
         if appearanceRing(1) > 0

             statusPassed = strfind(trigger, 'passed_1');
             appearanceStatusPassed= size(statusPassed{1,1});
             if appearanceStatusPassed(1) > 0
                 result = {'1'};
             else
                 result = {'0'};
             end
         end
     end
end


function result = progressRowsNumbersIfNeeded(currentRowIndex, currentNbackRow,...
    currentRingRow, currentTrialType)
    if currentTrialType == 'nBack'
        currentNbackRow = currentRowIndex;
        currentRowIndex = currentRowIndex + 1;

    elseif currentTrialType == 'ring'
        currentRingRow = currentRowIndex;
        currentRowIndex = currentRowIndex + 1;
    else
        currentRowIndex = currentRowIndex + 1;
        
    end
    result = [currentRowIndex, currentNbackRow, currentRingRow];
end

function isStartInstructions(trigger, n, timeVector)
    global blockNumberInt;
    global startInstructions;  
    global titles;
    global startMagnetTime;
    global endBlockTime;
    
    title = titles(n);
    if strcmp(title{1}, 'taskMarkers')
        startInstructions_ = strfind(trigger, 'instructions_start');
        appearancenStartInstructions = size(startInstructions_{1,1});
        if appearancenStartInstructions(1) > 0
           startInstructions = timeVector(n);
           if blockNumberInt == -1 || blockNumberInt == 10 
               startMagnetTime = timeVector(n) - 9;
               endBlockTime = startMagnetTime;
           end
        end
    end
end


function isEndInstructions(trigger, n, timeVector)
    global endInstructions;
    global titles;

    title = titles(n);
    if strcmp(title{1}, 'taskMarkers')
        endInstructions_ = strfind(trigger, 'instructions_end');
        appearancenStartInstructions = size(endInstructions_{1,1});
        if appearancenStartInstructions(1) > 0
           endInstructions = timeVector(n);
        end
    end
end

function isStartFixation(trigger, n, timeVector)
    global startFixation;
    global titles;
    title = titles(n);
    if strcmp(title{1}, 'taskMarkers')
        startFixation_ = strfind(trigger, 'fixation_start');
        appearancenstartFixation_ = size(startFixation_{1,1});
        if appearancenstartFixation_(1) > 0
           startFixation = timeVector(n);
        end
    end
end

function isEndFixation(trigger, n, timeVector)
    global endFixation;
    global titles;

    title = titles(n);
    if strcmp(title{1}, 'taskMarkers')
        endFixation_ = strfind(trigger, 'fixation_end');
        appearancenendFixation_ = size(endFixation_{1,1});
        if appearancenendFixation_(1) > 0
           endFixation = timeVector(n);
        end
    end
end

function result = isNbackResponse(trigger, n)
     global lastLetter;
     global titles;
     result = 'None';
     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         nBack = strfind(trigger, 'nBack_expected');
         appearancenBack = size(nBack{1,1});
         if appearancenBack(1) <= 0 || lastLetter == ""
             result = 'None';
         else
            expected = extractBefore(extractAfter(trigger, "expected_"),"_");
            actual = extractAfter(trigger, "actual_");
            expected = expected{1};
            actual = actual{1};
            if expected == '1'
                if actual== '1'
                    result = 'HIT';
                else
                    result = 'MISS';
                end
            else
                if actual == '1'
                    result = 'FA';
                else
                    result = 'CorrectRejection';
                end 
            end
         end
     end
end

function checkIfEndTrigger(trigger, n, timeVector)
     global blockTimes
     global blockNumberInt
     global startMagnetTime
     global endBlockTime;
     global movementsAmount;
     global pitchDirectionChanges;
     global yawDirectionChanges;
     global titles;

     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         startIndices = strfind(trigger, 'runEnd');
         appearance = size(startIndices{1,1});
         if appearance(1) ~= 0
             blockTimes{blockNumberInt,9} = timeVector(n) - startMagnetTime;
             blockTimes{blockNumberInt,14} = movementsAmount;
             blockTimes{blockNumberInt,17} = pitchDirectionChanges;
             blockTimes{blockNumberInt,18} = yawDirectionChanges;
             blockNumberInt = blockNumberInt + 1;
             endBlockTime = timeVector(n);
         end
     end
end

function isJoystickMovement(trigger ,n )
     global movementsAmount;
     global titles;
     
     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         StickMvmtPitch = strfind(trigger, 'pitch');
         StickMvmtYaw = strfind(trigger, 'yaw');
         appearanceStickMvmtPitch = size(StickMvmtPitch{1,1});
         appearanceStickMvmtYaw = size(StickMvmtYaw{1,1});
         if appearanceStickMvmtPitch(1) > 0 || appearanceStickMvmtYaw(1) > 0
             movementsAmount = movementsAmount + 1;
         end
     end
end

function result = checkIfYawOrPitch(trigger, n)
     global pitchDirectionChanges;
     global yawDirectionChanges;
     global lastPitchChangeSign;
     global lastYawChangeSign;
     global lastPitchValue;
     global lastYawValue;
     
     global titles;
     title = titles(n);
     trigger = trigger{1};
     result = 1;
     if strcmp(title{1}, 'yaw')        
         currentChangeSign = trigger - lastYawValue;
         lastYawValue = trigger;
         temp = currentChangeSign;
         if temp > 0
             currentChangeSign = 1;
         elseif temp < 0
             currentChangeSign = -1;
         end

     elseif  strcmp(title{1}, 'pitch') 
         currentChangeSign = trigger - lastPitchValue;
         lastPitchValue = trigger;
         temp = currentChangeSign;
         if temp > 0
             currentChangeSign = 1;
         elseif temp < 0
             currentChangeSign = -1;
         end
     else
         result = 0;
         return;
     end
     if strcmp(title{1}, 'yaw') && (currentChangeSign ~= lastYawChangeSign)
         lastYawChangeSign = currentChangeSign;
         yawDirectionChanges = yawDirectionChanges + 1;
     elseif strcmp(title{1}, 'pitch') && (currentChangeSign ~= lastPitchChangeSign)
         lastPitchChangeSign = currentChangeSign;
         pitchDirectionChanges = pitchDirectionChanges + 1;         
     end
end

function checkIfStartTrigger(trigger, n, timeVector, defaultSubName)
     global subId;
     global condition;
     global level;
     global ringSize;
     global isPractice;
     global blockNumber;
     global speed;
     global difficultLevel;
     global startTime;
     global blockType;
     global blockTimes;
     global blockNumberInt;
     global startMagnetTime;
     global isBaseline;
     global endFixation;
     global startFixation;
     global endInstructions;
     global startInstructions;
     global endBlockTime;
     global movementsAmount;
     global titles;
     global pitchDirectionChanges;
     global yawDirectionChanges;
     global lastPitchChangeSign;
     global lastYawChangeSign;
     global lastPitchValue;
     global lastYawValue;
     
     title = titles(n);
     if strcmp(title{1}, 'taskMarkers')
         startIndices = strfind(trigger, 'runStart');
         appearance = size(startIndices{1,1});
         if appearance(1) ~= 0
             if ~ismissing(extractAfter(string(trigger), "subjectNumber_"))
                 subId = extractBefore(extractAfter(trigger, "subjectNumber_"),"_");
             else
                 subId = defaultSubName;
             end

             pitchDirectionChanges = 0;
             yawDirectionChanges = 0;
             lastPitchChangeSign = 0;
             lastYawChangeSign = 0;
             lastPitchValue = 0;
             lastYawValue = 0;
             movementsAmount = 0;
             condition = extractBefore(extractAfter(trigger, "condition_"),"_");
             level = extractBefore(extractAfter(trigger, "nLevel_"),"_"); 
             ringSize =  extractBefore(extractAfter(trigger, "ringSize_"),"_"); 

             isPractice =  extractBefore(extractAfter(trigger, "isPractice_"),"_");
             blockNumber =  extractBefore(extractAfter(trigger, "blockNumber_"),"_"); 
             blockType = extractBefore(extractAfter(trigger, "blockOrdinal_"),"_");
             isBaseline = extractBefore(extractAfter(trigger, "isBaseline_"),"_"); 
             speed = extractBefore(extractAfter(trigger, "speed_"),"_");
             startTime = timeVector(n);

             if blockNumber == "0"
                 blockNumberInt = 1;
             end


             if char(level) == '0'
                 isBaseline = "True";
             end
             blockTimes{blockNumberInt,1} = char(level);
             blockTimes{blockNumberInt,2} = char(ringSize);
             blockTimes{blockNumberInt,3} = char(isPractice);
             blockTimes{blockNumberInt,4} = char(blockType);
             blockTimes{blockNumberInt,5} = char(condition);
             blockTimes{blockNumberInt,6} = char(blockNumber);
             blockTimes{blockNumberInt,7} = char(isBaseline);
             blockTimes{blockNumberInt,8} = startTime - startMagnetTime;
             blockTimes{blockNumberInt,10} = endInstructions - startInstructions;
             blockTimes{blockNumberInt,11} = endFixation - startFixation;
             blockTimes{blockNumberInt,12} = startInstructions - endBlockTime;
             blockTimes{blockNumberInt,13} = startTime - endFixation;
             blockTimes{blockNumberInt,15} = char(subId);

             calculateDifficultLevel();

             blockTimes{blockNumberInt,16} = difficultLevel;
         end
     end
end

function result = calculateNbackScore(dataTable)
    nbackVector = dataTable(:,5);
    hitAmount = 0;
    missAmount = 0;
    faAmount = 0;
    correctRegectionAmount = 0;
    
    vecotorSize = size(nbackVector);
    for responseIndex = 1: vecotorSize(1)
        if string(nbackVector(responseIndex)) == "HIT"
            hitAmount = hitAmount + 1;
        elseif string(nbackVector(responseIndex)) == "MISS"
            missAmount = missAmount + 1;
        elseif string(nbackVector(responseIndex)) == "CorrectRejection"
            correctRegectionAmount = correctRegectionAmount + 1;
        elseif string(nbackVector(responseIndex)) == "FA"
            faAmount = faAmount + 1  ;
        end
    end
    result = hitAmount / (hitAmount + missAmount) - faAmount / (faAmount + correctRegectionAmount);
end

function calculateDifficultLevel()
     global level;
     global ringSize ;
     global difficultLevel;
     global isBaseline;
     
     if string(isBaseline{1,1}) == "True"        
         difficultLevel = 0;
         if string(ringSize{1,1}) == 'big'
             difficultLevel = 10;
         elseif string(ringSize{1,1}) == 'medium'
             difficultLevel = 20;
         elseif string(ringSize{1,1}) == 'small'
             difficultLevel = 30;            
         end         

     elseif level{1,1} == '1'
         if string(ringSize{1,1}) == 'big'
             difficultLevel = 1;
         elseif string(ringSize{1,1}) == 'medium'
             difficultLevel = 2;
         end
     elseif level{1,1} == '2'
         if string(ringSize{1,1}) == 'medium'
             difficultLevel = 3;
         else
             difficultLevel = 4;
         end
     else
         difficultLevel = 5;
     end
end
