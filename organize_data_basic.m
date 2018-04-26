function [dataTableNbackResFinal blockTimesNbackResFinal....
    dataTableStroopResFinal, blockTimesStroopResFinal] = organize_data_basic...
                    (timeVector, triggersVector, defaultSubName)

    global subIdIndex;
    global timeIndex;
    global rtIndex;
    global conditionIndex;
    global isPracticeIndex;
    global isSuccessIndex;
    global blockNumberIndex; 
    global taskSpecificConditionIndex;
    global stimulusIndex;
    global orderIndex;
    
    %only nback
    global responseTypeIndex;
    
    global currentNbackRow;
    global currentStroopRow;
    
    global subId;
    global startTime;
    global startMagnetTime;
    global endInstructions;
    global startInstructions;
    global endFixation;
    global startFixation;
    global condition;
    global taskCondition;
    global isPractice;
    global lastStimulusTime;
    global lastStimulus;
    global blockNumber;
    global blockNumberInTask;
    global blockType;
    global endBlockTime;
    global currentTask;
    global lastResponseRT;
    global lastTrialSuccess;
    global nBackLastTrialResultType;
    global dataTableNbackRes;
    global dataTableStroopRes;
    global blockTimesNbackRes;
    global blockTimesStroopRes;

    subIdIndex = 1;
    timeIndex = 2;
    rtIndex = 3;
    conditionIndex = 4;
    isPracticeIndex = 5;
    isSuccessIndex = 6;
    blockNumberIndex = 7; 
    taskSpecificConditionIndex = 8;
    stimulusIndex = 9;
    orderIndex = 10;
    
    %only nback
    responseTypeIndex = 11;
    currentTask = "";
    lastStimulus = "";
    blockNumberStroopInt = 1;
    blockNumberNbackInt = 1;
    blockNumberInTask = 0;

    dataTableNbackRes = {};
    dataTableStroopRes = {};
    blockTimesNbackRes = {};
    blockTimesStroopRes = {};
    lastResponseRT = -1;
    for n = 1:numel(triggersVector)
    
        trigger = triggersVector(n);
        isStartTask(trigger);
        isStartStressEvaluation(trigger, n, timeVector);
        isStartInstructions(trigger, n, timeVector);
        isEndInstructions(trigger, n, timeVector);
        isStartFixation(trigger, n, timeVector);
        isEndFixation(trigger, n, timeVector);
        checkIfStartTrigger(trigger, n, timeVector);
        checkIfEndTrigger(trigger, n, timeVector);
        checkIfKey(trigger, n, timeVector);
        
        if currentTask == "stroop"
            checkIfArrow(trigger, n, timeVector);
        else
            checkIfLetter(trigger);
            checkIfLocation(trigger, n, timeVector);
        end

        isEndTrial = isTrialResult(trigger);
        if isEndTrial ~= "None"
            updatePerformanceTable();
        end
    end
    
    dataTableNbackResFinal = dataTableNbackRes;
    dataTableStroopResFinal = dataTableStroopRes;
    blockTimesNbackResFinal = blockTimesNbackRes;
    blockTimesStroopResFinal = blockTimesStroopRes;

    
end

function updatePerformanceTable()
    global subIdIndex;
    global timeIndex;
    global rtIndex;
    global conditionIndex;
    global isPracticeIndex;
    global isSuccessIndex;
    global blockNumberIndex; 
    global taskSpecificConditionIndex;
    global stimulusIndex;
    global orderIndex;
    
    %only nback
    global responseTypeIndex;
    global order;
    global currentNbackRow;
    global currentStroopRow;
    global subId;
    global condition;
    global taskCondition;
    global isPractice;
    global lastStimulusTime;
    global lastStimulus;
    global blockNumber;
    global currentTask;
    global lastResponseRT;
    global lastTrialSuccess;
    global nBackLastTrialResultType;
    
    global dataTableNbackRes;
    global dataTableStroopRes;
    
    currentRow = 0;
    if currentTask == "stroop"
        dataTable = dataTableStroopRes;
        currentRow = currentStroopRow;
    else
        dataTable = dataTableNbackRes;
        currentRow = currentNbackRow;
        dataTable{currentRow,responseTypeIndex} = char(nBackLastTrialResultType);
    end

    dataTable{currentRow,subIdIndex} = char(subId);
    dataTable{currentRow,conditionIndex} = char(condition);
    dataTable{currentRow,timeIndex} = lastStimulusTime;
    
    dataTable{currentRow,rtIndex} = lastResponseRT;
    dataTable{currentRow,stimulusIndex} = char(lastStimulus);
    dataTable{currentRow,blockNumberIndex} = char(blockNumber);
    dataTable{currentRow,isPracticeIndex} = char(isPractice);
    dataTable{currentRow,isSuccessIndex} = char(lastTrialSuccess);
    dataTable{currentRow,taskSpecificConditionIndex} = char(taskCondition);
    dataTable{currentRow,orderIndex} = char(order);
    
    lastResponseRT = -1;
    if currentTask == "stroop"
        currentStroopRow = currentStroopRow + 1;
        dataTableStroopRes = dataTable;
    else
        currentNbackRow = currentNbackRow + 1;
        dataTableNbackRes = dataTable;
    end
end

function isStartStressEvaluation(trigger, n, timeVector)
    global blockNumberInTask;
    global startMagnetTime;
    global endBlockTime;
    eval = strfind(trigger, 'eval');
    appearancenEval = size(eval{1,1});
    if appearancenEval(1) > 0
        startStressV1 = strfind(trigger, 'start_1_type_stress');
        tartStressV2 = strfind(trigger, 'start_1_stress_1');
        appearancenStartStressV1 = size(startStressV1{1,1});      
        appearancenStartStressV2 = size(tartStressV2{1,1});  
        if ((appearancenStartStressV1(1) > 0) && (blockNumberInTask == 0))...
            || (appearancenStartStressV2(1) > 0) && (blockNumberInTask == 0)
           startMagnetTime = timeVector(n);
           endBlockTime = startMagnetTime;
        end
    end 
end

function result = checkIfLetter(trigger)
     global lastStimulus
     result = '';
     letter = strfind(trigger, 'letter');
     appearance = size(letter{1,1});
     if appearance(1) ~= 0
         result = extractAfter(trigger, "letter_letter_");
         lastStimulus = result;
     end
end

function result = checkIfArrow(trigger, n, timeVector)
     global lastStimulus
     global lastStimulusTime
     global startTime

     result = '';
     letter = strfind(trigger, 'arrow');
     appearance = size(letter{1,1});
     if appearance(1) ~= 0
         location = extractBefore(extractAfter(trigger, "location_"), "_");
         direction = extractAfter(trigger, "direction_");
         lastStimulus = strcat("location_", location{1},...
             "_direction_", direction{1});
         lastStimulusTime = timeVector(n) - startTime;
     end
end

function result = checkIfLocation(trigger, n, timeVector)
     global lastStimulus
     global lastStimulusTime
     global startTime
     result = '';
     location = strfind(trigger, 'location');
     appearance = size(location{1,1});
     if appearance(1) ~= 0
         result = extractAfter(trigger, "location_");
         lastStimulus = strcat(lastStimulus, "_", result{1});
         lastStimulusTime = timeVector(n) - startTime;
     end
end


function isStartInstructions(trigger, n, timeVector)
    global startInstructions;  
    startInstructions_ = strfind(trigger, 'instructions_start');
    appearancenStartInstructions = size(startInstructions_{1,1});
    if appearancenStartInstructions(1) > 0
       startInstructions = timeVector(n);
    end
end

function isStartTask(trigger)
    global currentTask;
    global currentNbackRow;
    global currentStroopRow;
    global blockNumberInTask;
    

    startTask = strfind(trigger, 'startTask');
    appearancenStartTask = size(startTask{1,1});
    if appearancenStartTask(1) > 0
       currentTask = string(extractAfter(trigger{1}, "_task_"));
       blockNumberInTask = 0;
       currentNbackRow = 0;
       currentStroopRow = 0;
    end
end

function isEndInstructions(trigger, n, timeVector)
    global endInstructions;
    startInstructions_ = strfind(trigger, 'instructions_end');
    appearancenStartInstructions = size(startInstructions_{1,1});
    if appearancenStartInstructions(1) > 0
       endInstructions = timeVector(n);
    end
end

function isStartFixation(trigger, n, timeVector)
    global startFixation;  
    startInstructions_ = strfind(trigger, 'fixation_start');
    appearancenStartInstructions = size(startInstructions_{1,1});
    if appearancenStartInstructions(1) > 0
       startFixation = timeVector(n);
    end
end

function isEndFixation(trigger, n, timeVector)
    global endFixation;
    startInstructions_ = strfind(trigger, 'fixation_end');
    appearancenStartInstructions = size(startInstructions_{1,1});
    if appearancenStartInstructions(1) > 0
       endFixation = timeVector(n);
    end
end

function result = isTrialResult(trigger)
     global lastTrialSuccess;
     global currentTask;
     global nBackLastTrialResultType;
     global currentNbackRow;
     global currentStroopRow;
     global lastResponseRT;
     
     result = 'None';
     lastTrialSuccess = '0';
     trialResult = strfind(trigger, 'trialResult');
     appearancenTrialResult = size(trialResult{1,1});
     if appearancenTrialResult(1) > 0
         
         if currentTask == "nBack"
            currentNbackRow = currentNbackRow + 1;
            resultType = strfind(trigger, 'resultType');
            appearancenResultType = size(resultType{1,1});
            if appearancenResultType(1) > 0
                result = '1';
                resultType = extractAfter(trigger, "resultType_");
                nBackLastTrialResultType = resultType{1};
                correctString = strfind(trigger, 'Correct');
                appearancenCorrectString = size(correctString{1,1});
                if appearancenCorrectString(1) > 0
                    lastTrialSuccess = '1';
                end
            end
         elseif currentTask ~= ""
            result = '1';
            currentStroopRow = currentStroopRow + 1;
            isSuccess = extractAfter(trigger, "success_");
            lastTrialSuccess = isSuccess{1}; 
         end
     end
end

function checkIfKey(trigger, n, timeVector)
     global lastResponseRT
     global lastStimulusTime
     global startTime

     startIndices = strfind(trigger, 'keyPressed');
     appearance = size(startIndices{1,1});
     if appearance(1) ~= 0
         lastResponseRT = timeVector(n) - lastStimulusTime - startTime;
     end
end


function checkIfStartTrigger(trigger, n, timeVector)
     global subId;
     global condition;
     global taskCondition;
     global isPractice;
     global blockNumber;
     global startTime;
     global blockTimes;
     global blockNumberInTask;
     global startMagnetTime;
     global endFixation;
     global startFixation;
     global endInstructions;
     global startInstructions;
     global endBlockTime;
     global currentTask;
     global blockTimesNbackRes;
     global blockTimesStroopRes;
     global order
     
     startIndices = strfind(trigger, 'startBlock');
     appearance = size(startIndices{1,1});
     if appearance(1) ~= 0
         blockNumberInTask = blockNumberInTask + 1;
         subId = extractBefore(extractAfter(trigger, "subNumber_"),"_");
         condition = '';
         if currentTask == "stroop"
            taskCondition = extractBefore(extractAfter(trigger, "_cond_"),"_"); 
         else
             taskCondition = extractBefore(extractAfter(trigger, "_level_"),"_");
         end
         
             
         isPractice =  extractBefore(extractAfter(trigger, "practice_"),"_");
         blockNumber =  extractAfter(trigger, "blockIndex_"); 
         startTime = timeVector(n);
         order =  extractBefore(extractAfter(trigger, "order_"),"_");
         if blockNumber == "1"
             blockNumberInTask = 1;
         end
         
         blockTimes = {};
         if currentTask == "stroop"
            blockTimes = blockTimesStroopRes;
         else
            blockTimes = blockTimesNbackRes;
         end
         blockTimes{blockNumberInTask,1} = char(taskCondition);
         blockTimes{blockNumberInTask,2} = char(isPractice);
         blockTimes{blockNumberInTask,3} = char(condition);
         blockTimes{blockNumberInTask,4} = char(blockNumber);
         blockTimes{blockNumberInTask,5} = startTime - startMagnetTime;
         blockTimes{blockNumberInTask,7} = endInstructions - startInstructions;
         blockTimes{blockNumberInTask,8} = endFixation - startFixation;
         blockTimes{blockNumberInTask,9} = startTime - endFixation;
         blockTimes{blockNumberInTask,10} = char(subId);
         blockTimes{blockNumberInTask,11} = char(order);
         
         if currentTask == "stroop"
            blockTimesStroopRes = blockTimes;
         else
            blockTimesNbackRes = blockTimes;
         end
     end
end


function checkIfEndTrigger(trigger, n, timeVector)
     global blockTimes
     global startMagnetTime
     global endBlockTime;
     
     global blockTimesNbackRes;
     global blockTimesStroopRes;
     global blockNumberInTask;
     global currentTask;

     startIndices = strfind(trigger, 'endBlock');
     appearance = size(startIndices{1,1});
     if appearance(1) ~= 0 &&  currentTask ~= ""  
         blockTimes = {};
         if currentTask == "stroop"
            blockTimes = blockTimesStroopRes;
         else
            blockTimes = blockTimesNbackRes;
         end
         blockTimes{blockNumberInTask,6} = timeVector(n) - startMagnetTime;
         endBlockTime = timeVector(n);

         if currentTask == "stroop"
            blockTimesStroopRes = blockTimes;
         else
            blockTimesNbackRes = blockTimes;
         end
     end
end



