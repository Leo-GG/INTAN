function [peaks_t chWaves]= std_spike_det(filteredData,nStd,inv)
% Simple threshold-based peak detection. Peaks are detected as multiples of
% the channel standard deviation. 
% 
% filteredData: single chanel voltage trace
% nStd: number of std multiples to use as threshold
% inv: signed integer to invert (for negative peaks) or not (for positive
%      ones) the voltage trace
    
    nSamples = length(filteredData);
    peaks=[];
    waveforms=[];
    
    % Estimate the noise as the channel std (not robust)
    noiseStd=std(filteredData);
    % Peak detection
    [pks_, times_] = findpeaks(filteredData.*inv, 'MINPEAKHEIGHT',...
        noiseStd*nStd,'MINPEAKDISTANCE', 5000);
    % Trim peaks at the beginning and end of the recording and peaks above
    % 400uV or below 80uV
    peaks_t=times_(times_>5000 & times_<(nSamples-5000) &...
        pks_<400 & pks_>80);
    % Store waveforms around the detected peaks
    chWaves=[];
    for i=1:length(peaks_t)
        wave=filteredData(peaks_t(i)-5000:peaks_t(i)+5000);
        chWaves=[chWaves,wave];
    end
end