%% The script for extracting the epoch for confirmation-bias experiment 

% Author: Yangyulin Ai
% Email: Yangyulin Ai-1@student.uts.edu.au


%% 启动 EEGLAB

%[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;

% ALLEEG: 这是一个 MATLAB 结构体数组，用于存储所有在 EEGLAB 会话中加载的 EEG 数据集。每个元素都是一个独立的 EEG 数据集。
% EEG: 这是一个 MATLAB 结构体，代表当前活跃（或正在处理）的 EEG 数据集。EEGLAB 的大多数函数都是对这个变量进行操作。
% CURRENTSET: 这是一个整数，表示 ALLEEG 数组中当前活跃的 EEG 数据集的索引。
% ALLCOM: 这是一个存储所有执行过的 EEGLAB 命令的字符串单元格数组。它可以用来复现分析步骤或生成 MATLAB 脚本。

eeglab nogui; %无GUI的方式

%% 加载数据集

subjectID = 19;
folderPath = ['C:\Data\EEG Data\EEG\S' num2str(subjectID)];
dataset = ['S' num2str(subjectID) '_cleaned.set'];

% folderPath = sprintf('C:\\Data\\EEG Data\\EEG\\S%d', subjectID); % 方法2

EEG = pop_loadset('filename', dataset, 'filepath', folderPath);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

% 最后的 0 表示将当前的 EEG 数据集存储为 ALLEEG 数组中的新元素。如果你使用其他的索引值，则会替换 ALLEEG 中对应索引的数据集。

%% 提取epoch

conditions = {'Negative', 'Positive', '1', '2', '4', '5'};

for con = 1:length(conditions)
  EEG = ALLEEG(1);
  %eeglab redraw;
  condition = conditions{con};
    
  if strcmp(condition, 'Negative') || strcmp(condition, 'Positive')
      for i = 1:length(EEG.event)
            if strcmp(num2str(EEG.event(i).type), '9') % 事件标记 “9” 表示患者的反应
                % 寻找一个数字的标记，因为下一个标记肯定是其四位数的标记，所以做 i+1

                decimal = str2double(EEG.event(i+1).type(5)); % 从 .1 到 .5
                if decimal > 3  % 4 或 5            
                    EEG.event(i-2).type = 'Positive';
                elseif decimal < 3 % 1 或 2            
                    EEG.event(i-2).type = 'Negative';
                else % 3
                    EEG.event(i-2).type = 'Natrual';
                end
            end
      end
  else
      for i = 1:length(EEG.event)
            if strcmp(num2str(EEG.event(i).type), '9')
                decimal = str2double(EEG.event(i+1).type(5));  
                if decimal == 1 
                    EEG.event(i-2).type = '1';
                elseif decimal == 2 
                    EEG.event(i-2).type = '2';
                elseif decimal == 3 
                    EEG.event(i-2).type = '3';
                elseif decimal == 4 
                    EEG.event(i-2).type = '4';
                else
                    EEG.event(i-2).type = '5';
                end
            end
       end
  end
    
  % 确定与该条件相关的事件类型
  eventType = condition;  

  % 设置 epoch 提取的时间窗口
  timeWindow = [-0.5 1];  % 单位为秒

  % 提取特定条件的 epochs
  EEG = pop_epoch(EEG, {eventType}, timeWindow, 'newname', eventType, 'epochinfo', 'yes'); 
  EEG = pop_rmbase( EEG, [-500 0] ,[]); % 基线删除
  EEG = eeg_checkset( EEG ); % eeg_checkset 函数用于检查 EEG 数据集的一致性和完整性。这是一个好习惯，可以确保数据集在经过修改后仍然是有效和一致的。
  filename = 'default';

  if strcmp(condition, 'Negative')
    filename = ['S' num2str(subjectID) '_negative.set'];
  elseif strcmp(condition, 'Positive')
    filename = ['S' num2str(subjectID) '_positive.set'];
  else
    filename = ['S' num2str(subjectID) '_class' '_' num2str(condition) '.set'];
  end

  EEG = pop_saveset( EEG, 'filename',filename,'filepath', folderPath);


end