% Example script to import and analyze data from the RHD2000 evaluation 
% board from INTAN Technologies.


%% Load INTAN files
[fileName filePath] = uigetfile('*','Select the recording');
brwPathPre = strcat(filePath,fileName);
% Import parameters and voltage traces
[ch_data,t_data,params]=read_Intan_RHD2000_file(fileName,filePath);
% Plot sample of original data
figure; plot(t_data, ch_data(1,:)); title('Input data, CH 1');

%% Substract mean
subsMean=[];
subsMean = bsxfun(@minus, ch_data, mean(ch_data,1));
subsMean = subsMean-repmat(mean(subsMean,2), 1, size(subsMean,2));
% plot chip-mean substracted
figure; plot(t_data, subsMean(1,:)); title('Mean substracted data, CH 1');

%% Spike det
spike_t=[];
spike_c=[];
spike_w=[];
amp_ch=[];
ISI_ch=[];
freq_ch=[];
% Do peak detection on each channel
for ch=1:64
    [peaks_t waveforms]=peak_det_std(subsMean(ch,:)',4,-1);
    % Store spike time, channel and waveform
    spike_t=[spike_t;peaks_t];
    spike_c=[spike_c;ones(numel(peaks_t),1).*ch];
    spike_w=[spike_w waveforms];
    % Compute mean peak amplitude, ISI and peak frequency for each channel
    amp_ch=[amp_ch mean(min(waveforms))];
    ISI_ch=[ISI_ch ...
        mean(diff(peaks_t))./params.amplifier_sample_rate];
    freq_ch=[freq_ch numel(peaks_t)/(t_data(end)-t_data(1))];
end
