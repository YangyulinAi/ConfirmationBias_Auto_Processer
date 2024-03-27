%% The script for preprocessing for confirmation-bias experiment 

% Author: Yangyulin Ai
% Email: Yangyulin Ai-1@student.uts.edu.au

%% 启动 EEGLAB

eeglab nogui; %无GUI的方式

%% 加载数据集

%subjectID = 19;
folderPath = ['C:\Users\m1760\OneDrive\Remote Disk (D) (Software)\Data\EEG Data\EEG\S' num2str(subjectID)];
dataset = [folderPath '\raw.xdf'];

EEG = pop_loadxdf(dataset , 'streamtype', 'EEG', 'exclude_markerstreams', {});
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

% 最后的 0 表示将当前的 EEG 数据集存储为 ALLEEG 数组中的新元素。如果你使用其他的索引值，则会替换 ALLEEG 中对应索引的数据集。

%% 降采样至250Hz
EEG = pop_resample( EEG, 250);

%% Channal Located
EEG=pop_chanedit(EEG, 'lookup','C:\\Data\\Software\\MATLAB\\toolbox\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc');

%% 高通滤波1Hz
EEG = pop_eegfiltnew(EEG, 'locutoff',1);

%% 低通滤波45Hz
EEG = pop_eegfiltnew(EEG, 'hicutoff',45);

%% 陷通滤波50Hz 去除线路噪声
EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist',[1:32] ,'computepower',1,'linefreqs',50,'newversion',0,'normSpectrum',0,'p',0.01,'pad',2,'plotfigures',0,'scanforlines',0,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);

%% 去掉ref通道
EEG = pop_select( EEG, 'rmchannel',{'Ref'});

%% 过滤坏通道
EEG = pop_rejchan(EEG, 'elec',[1:31] ,'threshold',5,'norm','on','measure','kurt');% 这里是因为32通道数据，ref被去掉，剩下31

% 计算剩余的通道数
nChannels = size(EEG.data, 1);

% 确定ICA的成分数 (通常是通道数减一)
nComponents = max(1, nChannels - 1); % 确保成分数至少为1

%% 删除实验block间隙的噪声

% 获取所有事件的时间点
eventTimes = [EEG.event.latency];

% 转换为秒
eventTimes = eventTimes / EEG.srate; % 计数除以采样率等于秒数，数组

% 初始化要删除的时间段的开始和结束索引
toDelete = [];

% 删除第一个事件标记之前的内容
if eventTimes(1) > 0
    toDelete = [toDelete; [0, eventTimes(1)-0.1]];% 留了0.1秒钟，因为从0开始第一个Marker会被吞掉
end


% 检查两个事件标记之间的间隔
for i = 1:length(eventTimes) - 1
    if (eventTimes(i + 1) - eventTimes(i)) > 20  % 20秒间隔
        toDelete = [toDelete; [eventTimes(i)+0.1, eventTimes(i + 1)-0.1]];
    end
end

% 删除最后一个事件标记之后的内容
if eventTimes(end) < EEG.xmax
    toDelete = [toDelete; [eventTimes(end)+0.1, EEG.xmax]];% 留了0.1秒钟
end

% 转换时间为数据点索引
toDelete = toDelete * EEG.srate;

% 逐个删除指定区间
for i = size(toDelete, 1):-1:1 % 这里需要从后往前遍历，因为从前往后会让原本的数据时间点混乱
    EEG = eeg_eegrej(EEG, toDelete(i, :));
end


%% 重参考
EEG = pop_reref( EEG, []);

%% 运行ICA
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','off', 'pca', nComponents, 'verbose', 'off');
%EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',30);

%% 源定位
EEG = pop_dipfit_settings( EEG, 'hdmfile','C:\\Data\\Software\\MATLAB\\toolbox\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\standard_vol.mat','mrifile','C:\\Data\\Software\\MATLAB\\toolbox\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\standard_mri.mat','chanfile','C:\\Data\\Software\\MATLAB\\toolbox\\eeglab2023.1\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc','coordformat','MNI','coord_transform',[0 0 0 0 0 0 1.0309 1.0309 1.0309] ,'chansel',[1:nChannels] );
EEG = pop_dipfit_gridsearch(EEG, [1:nComponents] ,[-85     -77.6087     -70.2174     -62.8261     -55.4348     -48.0435     -40.6522     -33.2609     -25.8696     -18.4783      -11.087     -3.69565      3.69565       11.087      18.4783      25.8696      33.2609      40.6522      48.0435      55.4348      62.8261      70.2174      77.6087           85] ,[-85     -77.6087     -70.2174     -62.8261     -55.4348     -48.0435     -40.6522     -33.2609     -25.8696     -18.4783      -11.087     -3.69565      3.69565       11.087      18.4783      25.8696      33.2609      40.6522      48.0435      55.4348      62.8261      70.2174      77.6087           85] ,[0      7.72727      15.4545      23.1818      30.9091      38.6364      46.3636      54.0909      61.8182      69.5455      77.2727           85] ,0.4);


%% 标记坏组件

% 在 EEGLAB 中，要通过代码标记某个独立成分（Independent Component，简称 IC）为拒绝（reject），
% 您可以直接操作 EEG 结构中的相关字段。
% EEGLAB 使用 EEG.reject.gcompreject 数组来存储关于是否拒绝特定独立成分的信息。
% 每个成分在这个数组中有一个对应的逻辑值（0 或 1），其中 1 表示拒绝该成分，0 表示保留。
EEG = pop_iclabel(EEG, 'default');

% 1. 如果一个组件的最高分类不是brain，标记为拒绝
% 检查 ICLabel 结果是否存在
if isfield(EEG.etc, 'ic_classification') && isfield(EEG.etc.ic_classification, 'ICLabel')
    % 获取 ICLabel 的分类结果
    icLabelScores = EEG.etc.ic_classification.ICLabel.classifications;
    % 这是一个组件*7的数组，其中1-7分别是：
        % Brain：大脑信号，指的是与大脑活动相关的信号。
        % Muscle：肌肉伪迹，来自于肌肉活动，特别是面部和颈部肌肉。
        % Eye：眼动伪迹，来自眼球运动（如眨眼或快速眼动）。
        % Heart：心脏伪迹，可能来自心电活动。
        % Line Noise：线路噪声，通常指的是电源线产生的固定频率干扰，如50Hz或60Hz。
        % Channel Noise：通道噪声，指的是特定通道的噪声，可能由设备故障或其他非生理性源引起。
        % Other：其他类型的信号，不属于上述任何一类。

    % 找出每个成分最高可能性的类别
    [maxScores, maxCategories] = max(icLabelScores, [], 2);
    % max(..., 2)：这里的 2 指定 max 函数沿着矩阵的第二维度（即列）操作。这意味着函数会在 icLabelScores 的每一行中寻找最大值。
    % []：这是一个占位符，用于指定函数的第二个参数。在这种用法中，它告诉 MATLAB 我们要找的是矩阵中的最大值，而不是两个数值或数组的最大值。

    % 定义大脑相关的类别索引，假设它们是前三个（根据 ICLabel 的类别设置）
    brainCategories = 1; % 1='大脑'

    % 初始化拒绝数组
    EEG.reject.gcompreject = zeros(1, size(EEG.icaweights, 1)); % 初始化为全0数组

    % 遍历每个成分，判断最高可能性的类别是否为非大脑
    for i = 1:size(icLabelScores, 1)
        if ~ismember(maxCategories(i), brainCategories)
            % 如果最高可能性的类别不是大脑相关，标记为拒绝
            text = ['Debug (Class):' num2str(i) ':' num2str(maxCategories(i))];
            disp(text)

            EEG.reject.gcompreject(i) = 1;
        end
    end
else
    disp('ICLabel 结果未找到，请先运行 ICLabel。');
end

% 2. 如果一个组件的RV小于15%，被标记为拒绝
% 检查是否已经进行了源定位并有剩余方差的数据
if isfield(EEG, 'dipfit') && isfield(EEG.dipfit, 'model')
    % 遍历所有的独立成分
    for i = 1:length(EEG.dipfit.model)
        % 检查是否有 rv 数据并且是否大于 15%
        if isfield(EEG.dipfit.model(i), 'rv') && EEG.dipfit.model(i).rv > 15 %0.15
            % 标记该成分为拒绝
            text = ['Debug (RV):' num2str(i) ':' num2str(EEG.dipfit.model(i).rv)];
            disp(text);
            EEG.reject.gcompreject(i) = 1;
        end
    end
else
    disp('源定位未完成或剩余方差信息不存在。');
end

%% 保存数据集
EEG = pop_editset(EEG, 'setname', 'cleaned');
datasetName = ['S' num2str(subjectID) '_cleaned.set'];
EEG = pop_saveset( EEG, 'filename', datasetName,'filepath', folderPath);
