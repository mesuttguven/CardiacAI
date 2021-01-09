function [selected_feature_table_all,N] = extract_selected_features(fds, window_length, window_overlap, reference_table)


warning off
overlap_length = window_length * window_overlap / 100;
step_length = window_length - overlap_length;
selected_feature_table_all = table();
labelMap = containers.Map('KeyType','int32','ValueType','char');
keySet = {-1, 1};
valueSet = {'Normal','Abnormal'};
labelMap = containers.Map(keySet,valueSet);

while hasdata(fds)
    PCG = read(fds);
    
    signal = PCG.data;
    fs = PCG.fs;
    
    [ STD12, T12, STD21, T21, Rejected_Peak_Rate, Amplitude_Rate ] = common_features(signal, fs);
        
    current_class = reference_table(strcmp(reference_table.record_name, PCG.filename), :).record_label;
    
    N = length(signal);        % Bernhard: to keep track of #samples in files we process
    number_of_windows = floor( (N - overlap_length*fs) / (fs * step_length));
    
    feature_table = table();
    for iwin = 1:number_of_windows
        current_start_sample = (iwin - 1) * fs * step_length + 1;
        current_end_sample = current_start_sample + window_length * fs - 1;
        current_signal = signal(current_start_sample:current_end_sample);
        
        
        %** 1 Calculate skewness of the signal values
        feature_table.sampleSkewness(iwin, 1) = skewness(current_signal);
        %** 2 Calculate kurtosis of the signal values
        feature_table.sampleKurtosis(iwin, 1) = kurtosis(current_signal);
        %** 3 Calculate Shannon's entropy value of the signal
        feature_table.signalEntropy(iwin, 1) = signal_entropy(current_signal');
          
               
        % Extract Mel-frequency cepstral coefficients
        Tw = window_length*1000;% analysis frame duration (ms)
        Ts = 10;                % analysis frame shift (ms)
        alpha = 0.97;           % preemphasis coefficient
        M = 20;                 % number of filterbank channels 
        C = 12;                 % number of cepstral coefficients
        L = 22;                 % cepstral sine lifter parameter
        LF = 5;                 % lower frequency limit (Hz)
        HF = 500;               % upper frequency limit (Hz)
        
        [MFCCs, ~, ~] = mfcc(current_signal, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L);
        
        feature_table.MFCC1(iwin, 1) = MFCCs(1);   % 4
        feature_table.MFCC2(iwin, 1) = MFCCs(2);   % 5
        feature_table.MFCC3(iwin, 1) = MFCCs(3);   % 6
        feature_table.MFCC4(iwin, 1) = MFCCs(4);   % 7
        feature_table.MFCC5(iwin, 1) = MFCCs(5);   % 8
        feature_table.MFCC6(iwin, 1) = MFCCs(6);   % 9
        feature_table.MFCC7(iwin, 1) = MFCCs(7);   % 10
        feature_table.MFCC8(iwin, 1) = MFCCs(8);   % 11
        feature_table.MFCC9(iwin, 1) = MFCCs(9);   % 12
        feature_table.MFCC10(iwin, 1) = MFCCs(10); % 13
        feature_table.MFCC11(iwin, 1) = MFCCs(11); % 14
        feature_table.MFCC12(iwin, 1) = MFCCs(12); % 15
        feature_table.MFCC13(iwin, 1) = MFCCs(13); % 16
        %Common Features
        feature_table.common_1(iwin, 1) = STD12;   % 17
        feature_table.common_2(iwin, 1) = T12;     % 18
        feature_table.common_3(iwin, 1) = STD21;   % 19
        feature_table.common_4(iwin, 1) = T21;     % 20
        feature_table.common_5(iwin, 1) = Rejected_Peak_Rate; % 21
        feature_table.common_6(iwin, 1) = Amplitude_Rate;     % 22
        
        % Assign class label to the observation
        if iwin == 1
            feature_table.class = {labelMap(current_class)};
        else
            feature_table.class{iwin, :} = labelMap(current_class);
        end
        
    end
    
    selected_feature_table_all = [selected_feature_table_all; feature_table];
end