% EEGLAB history file generated on the 28-Feb-2024
% ------------------------------------------------
%% 启动 EEGLAB

eeglab nogui; %无GUI的方式

%% 加载数据集

folderPath = ['C:\Users\m1760\OneDrive\Remote Disk (D) (Software)\Data\EEG Data\EEG\S' num2str(subjectID)];
dataset = ['\S' num2str(subjectID) '_cleaned.set'];
final_dataset_name = ['\S' num2str(subjectID) '_ERPs'];

EEG = pop_loadset('filename', dataset, 'filepath', folderPath);
[ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, 0);

eventlist = [folderPath '\elist.txt'];
bin = [folderPath '\elist_bin.txt'];

% 找到所有被标记为拒绝的ICA分量的索引
rejectedComponents = find(EEG.reject.gcompreject);

% 如果有被拒绝的分量，则移除它们
if ~isempty(rejectedComponents)
    EEG = pop_subcomp( EEG, rejectedComponents, 0);
else
    disp('没有被标记为拒绝的ICA分量。');
end

EEG = eeg_checkset( EEG );

for i = 1:length(EEG.event)
            if EEG.event(i).type == '9' % Event Marker "9" is the patient responds
                % Find one digit marker, because the next marker is definately four
                % digits marker, so do i+1
                decimal = str2double(EEG.event(i+1).type(5)); % get the .1 to .5
                %UserResNum = [UserResNum, decimal];
                if decimal > 3  % 4 or 5
                    %UserRes = [UserRes, "Positive"];
                    EEG.event(i-2).type = '99'; %ERPLab not support string
                elseif decimal < 3 % 1 or 2
                    %UserRes = [UserRes, "Negative"];
                    EEG.event(i-2).type = '88';
                else % 3
                    %UserRes = [UserRes, "Neutral"];
                    EEG.event(i-2).type = '0';
        
                end
            end
        end

EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', eventlist ); % GUI: 28-Feb-2024 21:02:33
EEG  = pop_binlister( EEG , 'BDF', 'C:\Users\m1760\OneDrive\Remote Disk (D) (Software)\Data\EEG Data\EEG\Binlister_Rule.txt', 'ExportEL', bin, 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'Voutput', 'EEG' ); % GUI: 28-Feb-2024 21:03:07
EEG = pop_epochbin( EEG , [-500.0  1000.0],  'pre'); % GUI: 28-Feb-2024 21:03:24
EEG  = pop_artextval( EEG , 'Channel',  1:EEG.nbchan, 'Flag',  1, 'LowPass',  -1, 'Threshold', [ -100 100], 'Twindow', [ -500 995] ); % GUI: 28-Feb-2024 21:03:41
EEG = pop_interp(EEG, EEG.chaninfo.removedchans, 'spherical');

% 插值后检查通道数，确认是否为31
if length(EEG.chanlocs) ~= 31
    disp(['警告：通道数不是31，当前通道数为 ' num2str(length(EEG.chanlocs))]);
    % 如果因为插值后存在名为'ref'的通道导致通道数不正确，则移除它
    refChanIndexPost = find(strcmp({EEG.chanlocs.labels}, 'Ref'));
    if ~isempty(refChanIndexPost)
        EEG = pop_select(EEG, 'nochannel', refChanIndexPost);
    end
end

% 确认处理后的通道数
if length(EEG.chanlocs) == 31
    disp('通道数正确为31。');
else
    disp(['处理后的通道数仍然不正确，当前为 ' num2str(length(EEG.chanlocs)) '个通道。']);
end

pause(2);

% 计算ERP平均值
ERP = pop_averager(EEG, 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on');

erpname = ['\S' num2str(subjectID) '_ERP'];
erpfilename = [erpname '.erp'];


% 保存ERP数据
ERP = pop_savemyerp(ERP, 'erpname', erpname, 'filename', erpfilename, 'filepath', 'C:\Users\m1760\OneDrive\Remote Disk (D) (Software)\Data\EEG Data\EEG\ERPs\', 'Warning', 'on');


%Update the name of the dataset.
EEG.setname = final_dataset_name;

% Save the final version of the dataset as a file.
EEG = pop_saveset( EEG, 'filename', [EEG.setname '.set'], 'filepath', folderPath);

