% main.m
for subjectID = [9]
    clearvars -except subjectID; % 清除除了 subjectID 之外的所有变量
    clc;
    % 显示当前正在处理的受试者编号
    disp(['Processing Subject: ' num2str(subjectID)]);

    % 设置受试者编号（这里假设这两个脚本都使用 subjectID 变量）
    EEGPreprocessor; % 调用 EEG 预处理脚本
    EpochExtractor;  % 调用 Epoch 提取脚本
    ERPExtractor;
end
