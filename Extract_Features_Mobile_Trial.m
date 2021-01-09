function y  = exractFeaturesMdl(u)

desiredFs = 2000;

window_length = 5;    

current_signal = u(1:10000);
[r,c] = size (current_signal);
        if c ~= 1
          signal = current_signal';
          
        else
          signal = current_signal;
       end

c_signal = signal/32857;

features = zeros (1,15);
       

        % 9 Calculate kurtosis of the signal values
        features(1) = kurtosis(c_signal);

        % 12, 13, 14 Extract features from the power spectrum
        [maxfreq] = dominant_frequency_features(c_signal, desiredFs, 256, 0);
        
        features(2) = maxfreq;    % 12
        
  %      % Extract Mel-frequency cepstral coefficients
        Tw = window_length*1000;% analysis frame duration (ms)
        Ts = 10;                % analysis frame shift (ms)
        alpha = 0.97;           % preemphasis coefficient
        M = 20;                 % number of filterbank channels 
        C = 12;                 % number of cepstral coefficients
        L = 22;                 % cepstral sine lifter parameter
        LF = 5;                 % lower frequency limit (Hz)
        HF = 500;               % upper frequency limit (Hz)

       [MFCCs, ~, ~] = mfcc(c_signal, desiredFs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, L);
        
        features(3) = MFCCs(1);   % 15 
        features(4) = MFCCs(2);   % 16
        features(5) = MFCCs(3);   % 17
        features(6) = MFCCs(4);   % 18
        features(7) = MFCCs(5);   % 19
        features(8) = MFCCs(6);   % 20
        features(9) = MFCCs(7);   % 21
        features(10) = MFCCs(8);  % 22
        features(11) = MFCCs(9);  % 23
        features(12) = MFCCs(10); % 24
        features(13) = MFCCs(11); % 25
        features(14) = MFCCs(12); % 26
        features(15) = MFCCs(13); % 27
        
y = features;

end
