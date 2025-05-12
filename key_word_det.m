clc
clear
close all

%% Reading the audio files

path="G:\Voice_db";     % Path of the voice database

% keywords
key_words = ["Candy", "Chips", "Coffee", "Juice"];

Y = zeros(4,79,24000);      % 4 keywords, 79 files for each, 3s*fs values
for i = 1:length(key_words)
    s_f_path = strcat(path,"\",key_words(i));   % sub-folder paths
    audio_files = dir(fullfile(s_f_path,'*.wav'));
    for j = 1:length(audio_files) % num of files in s_f_path
        f_name = audio_files(j).name;   % file name
        f_path = strcat(s_f_path,"\",f_name);   % file-path
        [y1, fs] = audioread(f_path);   % reading the files
        Y(i,j,:) = y1;  % the 3D matrix for all the files
    end
end

F_mat = permute(Y,[3 2 1]);     % reordering the dimensions for 

%% calculating the mfcc coefficients 

coeffs = mfcc(F_mat(:,1,1),8000,'LogEnergy','replace');

% defaults for mfcc()
% window = hamming(round(0.03*fs),"periodic")
% windowLength = 240
% OverlapLength = round(fs*0.02)
% OverlapWindowLength = 160

coeffs(:,1) = [];   % omitting the first coefficient for better accuracy

[rows,cols] = size(coeffs);

F_mat_mfcc = zeros(rows,cols,79,4);

for i = 1:4
    for j = 1:79
        mfcc_current = mfcc(F_mat(:,j,i),8000,'LogEnergy','replace');
        mfcc_current(:,1) = [];
        F_mat_mfcc(:,:,j,i) = mfcc_current;
    end
end

%% Live-Testing

Fs = 8000;
nBits = 16;
NumChannels = 1;
device_ID = 0;



recObj = audiorecorder(Fs, nBits, NumChannels, device_ID);
disp('Start speaking....')

recordblocking(recObj,3);
disp('End of Recording.')

inp_real = getaudiodata(recObj);

%% MFCC Calculation for input sample

input_mfcc = mfcc(inp_real,8000,'LogEnergy','replace');
input_mfcc(:,1) = [];   %omitting the first coefficients

%% DTW calculation

dist = zeros(1,4);
for i = 1:4
    for j = 1:79
        dist(i) = dist(i) + dtw(input_mfcc', F_mat_mfcc(:,:,j,i)');
    end
end

%% Identification

[dmin, min_idx] = min(dist);

disp(key_words(min_idx))

if min_idx == 1
    imshow("candy.jpg")
    title("Candy",'FontSize',18,'FontWeight','bold')
elseif min_idx == 2
    imshow("chips.jpg")
    title("Chips",'FontSize',18,'FontWeight','bold')
elseif min_idx == 3
    imshow("coffee.jpg")
    title("Coffee",'FontSize',18,'FontWeight','bold')
elseif min_idx == 4
    imshow("juice.jpg")
    title("Juice",'FontSize',18,'FontWeight','bold')
else
    disp("Unknown")
end