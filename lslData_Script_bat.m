function y = generateExcelFile(fileName1, fileName2)
    files = dir('*.xdf');
    dataTable = {'subId', 'time', 'letter', 'rt', 'responseType',...
    'condition', 'isPractice', 'n', 'ringPassedStatusIndex',...
    'isSuccessNback', 'ringSize', 'blockNumber',...
    'speed', 'difficultLevel', 'isBaseline', 'blockType'};
    blockTimes = {'nLevel', 'ringSize', 'isPractice', 'blockType'...
       'condition', 'blockNumber' ,'isBaseline', 'startTime', 'endTime',...
       'instructionsLength', 'fixationLength', 'beforeInstructionsLength',...
       'afterFixationLength', 'joystickMovements','subId','difficultLevel',...
       'pitchDirectionChanges', 'yawDirectionChanges'};
    for file = files'
        data = load_xdf(file.name);
        
        times = [];
        markers = {};
        titles = {};
        
        for n = 1:numel(data)
            if string(data{1,n}.info.name) == "NEDE_StickMvmtPitch"
                times = [times, data{1,n}.time_stamps];
                markers = [markers, num2cell(data{1,n}.time_series)];
                amount = size(data{1,n}.time_series);
                pitchTitle = cell(1,amount(2));
                pitchTitle(:) = {'pitch'};
                titles = [titles, pitchTitle];
            end
            if string(data{1,n}.info.name) == "NEDE_StickMvmtYaw"
                times = [times, data{1,n}.time_stamps];
                markers = [markers, num2cell(data{1,n}.time_series)]; 
                amount = size(data{1,n}.time_stamps);
                yawTitle = cell(1,amount(2));
                yawTitle(:) = {'yaw'};
                titles = [titles, yawTitle];
            end
            if string(data{1,n}.info.name) == "NEDE_Markers"
                times = [times, data{1,n}.time_stamps];
                markers = [markers, num2cell(data{1,n}.time_series)];
                amount = size(data{1,n}.time_stamps);
                taskMarkersTitle = cell(1,amount(2));
                taskMarkersTitle(:) = {'taskMarkers'};
                titles = [titles, taskMarkersTitle];
            end
        end
        
        [a,sortedIndices] = sort(times);
        
        if ~isempty(strfind(file.name, "001"))
            [y x] = organize_data_bat_001...
                (times, markers,titles,sortedIndices, extractBefore(string(file.name), "."));
        elseif ~isempty(strfind(file.name, "003")) || ~isempty(strfind(file.name, "004"))
            [y x] = organize_data_bat_003_004...
                (times, markers,titles,sortedIndices, extractBefore(string(file.name), "."));   
        else
            [y x] = organize_data_bat_005_plus...
                (times, markers,titles,sortedIndices, extractBefore(string(file.name), "."));
        end
        dataTable = [dataTable;y];
        blockTimes = [blockTimes;x];

    end
    y = dataTable;
    xlswrite(fileName1,dataTable);
    xlswrite(fileName2,blockTimes);

end