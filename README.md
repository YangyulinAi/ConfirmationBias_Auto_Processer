# Confirmation Bias Auto Processer
This project is designed for the automated pre-precessing, extracting of EEG epochs, and generating ERPs in the Confirmation Bias experiment.

## Features
- Extract EEG epochs under specific conditions.
- Preprocess and analyze the epochs.

## Getting Started
These instructions will help you to set up and run the project on your local machine for development and testing purposes.

### Prerequisites

MATLAB R20XX
EEGLAB
ERPLab


### Installing

Clone the repo
Open MATLAB
Run the script



## Usage
Modify the `folderPath` and `subjectID` to ensure that all data is stored in the same folder, named with 'S' followed by a number (e.g., S1, S2, etc.). Ensure that each folder contains a file named 'Sx_cleaned.set' (where x is the subject number). Running the code will automatically retrieve epochs for all conditions, facilitating subsequent group-level analysis.

Example:
Set the folderPath and subjectID in the script.
Ensure each subject folder contains 'Sx_cleaned.set'.
Execute the script for epoch extraction.


## Contributing
Please read [CONTRIBUTING.md] for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Authors
- **Yangyulin Ai** - *Initial work* - [YangyulinAi]
## License
This project is licensed under the MIT License - see the [LICENSE.md] file for details.

## Acknowledgments
- Dr. Avinash Singh
- Hat tip to anyone whose code was used
- Anyone who uses and tests the project

---

# 认知偏见项目自动数据处理
本项目是为了Confirmation Bias项目进行Epoch的自动化提取。

## 功能
- 提取特定条件的 EEG Epochs。
- 对 Epochs 进行预处理和分析。

## 开始
这些说明将帮助您在本地机器上安装和运行该项目，用于开发和测试目的。

### 前提条件

MATLAB R20XX
EEGLAB


### 安装

克隆仓库
打开 MATLAB
运行脚本


## 使用
修改 folderPath 和 subjectID，确保全部的数据存储在同一个以 'S' 加数字命名的文件夹下。确保每一个文件夹下都有一个以 'Sx_cleaned.set' 命名的文件（其中x为受试者编号）。运行代码，将自动获取所有条件下的epoch，帮助进行下一步的Group level分析。

例如：
在脚本中设置 folderPath 和 subjectID。
确保每个受试者文件夹中包含 'Sx_cleaned.set'。
执行脚本进行 Epoch 提取。

## 贡献
请阅读 [CONTRIBUTING.md]了解为该项目贡献的流程。

## 版本控制
我们使用 [SemVer](http://semver.org/) 进行版本控制。

## 作者
- **Yangyulin Ai** - *初始工作* - [YangyulinAi]

## 许可证
该项目根据 MIT 许可证授权 - 有关详细信息，请参阅 [LICENSE.md]文件。

## 致谢
- Dr. Avinash Singh
- 感谢所有为该项目提供帮助的人。
- 感谢使用和测试该项目的任何人。

