
function [ STD12, T12, STD21, T21, Rejected_Peak_Rate, Amplitude_Rate ] = common_features(s, fs);

% THIS PART IS FOR FURTHER TESTS CONDUCTED IN ANOTHER PUBLICATION. THIS CODE IS USED TO COMPUTE HEAR RATE PER MINUTE, 
% FUNDEMANTAL HEART SOUNDS AND ARRHYTHMIA DIAGNOSE. THIS APK AND MODEL DOESN NOT INCLUDE COMMON FEATURES 
% SINCE COMPUTATION TIME IN OF THE ALGORITHM IN A MOBILE DEVICE TAKES 2-3 SECONDS IN 5 SECONDS-LONG WINDOWS.
% SO, THIS CODE PART AND COMMON FEATURES CAN BE USED IN LONGER TIME FRAMES SUCH AS 10 SECONDS LONG WIMDOW ANALYSIS
% MESUT GUVEN (PhD)


%   Inputs
%           s = signal;
%           s is the input speech signal (as vector)
%           fs is the sampling frequency (Hz) 
%   Outputs
%
%   STD12, T12, STD21, T21, Rejected_Peak_Rate, Amplitude_Rate 
%  % s=PCG_normal;
%--------------------------------------------------------------------------
% (DETECTION OF SPIKES/PEAKS)
     %t=(1/fs:1/fs:length(s)/fs);            % time vector
     %[up,down] = envelope(t,s,'linear');    % Envelope of the signal
     th = 0.2*(max(s));                      % choose th
     [pks,dep,pidx,didx] = peakdet(s,th);    % perform peak-dep detection
     
% 3.2 : EXTRA PEAK REJECTION 
      
    PkT     = (pidx/fs)*1000;       % Msn.
    PkA     = pks;                  % Peak value
    [r,c]   = size(PkT);
    a=1;
    RPksTime(a)=PkT(a)/1000;        % sn
    RPksAmp(a) =PkA(a);
    
    for i=2:r-2
        
        if (PkT(i+1)-PkT(i))<80 && (PkT(i+2)-PkT(i))>200 && PkT(i)-RPksTime(a)>200 && PkA(i)>PkA(i+1) %&& PkT(i)~=RPksTime(a) 
           a=a+1;
           RPksTime(a)=PkT(i)/1000;
           RPksAmp(a) =PkA(i);
        end

        if (PkT(i+1)-PkT(i))<80 && (PkT(i+2)-PkT(i))>200 && PkT(i)-RPksTime(a)>200 && PkA(i+1)>PkA(i) %&& PkT(i)~=RPksTime(i-1)
           a=a+1;
           RPksTime(a)=PkT(i+1)/1000;
           RPksAmp(a) =PkA(i+1);
        end

        if PkT(i+1)-PkT(i)>180 && PkT(i)-PkT(i-1)>180 && PkT(i)-RPksTime(a)>200 
           a=a+1;
           RPksTime(a)=PkT(i)/1000; 
           RPksAmp(a) =PkA(i);
        end
        
        if PkT(i)-RPksTime(a)>200 && PkT(i)-PkT(i-1)>180 && PkT(i+1)-PkT(i)>50 && PkA(i)>PkA(i+1)
           a=a+1;
           RPksTime(a)=PkT(i)/1000; 
           RPksAmp(a) =PkA(i);
        end
    end

    RT(1)=RPksTime(1); RA(1)=RPksAmp(1); u=2;
    for i=2:a
        if RPksTime(i)~=RPksTime(i-1)
           RT(u)= RPksTime(i);
           RA(u)= RPksAmp(i);
           u=u+1;           
        end
     end
    
RPksT=RT;       %Time indices after extra peak rejection 
RPksA=RA;       %Amplitude values after extra peak rejection 
   
clear RPksTime RPksAmp RT RA PkA PkT a i ;

% (SEGMENTATION)
%-------------------------------------------------------------------------- 
%**************************************************************************
% 3.3 : DETECTION OF S1-S2 ;

   D =diff(RPksT);
   [r,c] = size(RPksT);
   DisMat= zeros(c,3);
    
    for i=1:c                                 
        DisMat(i,1)= RPksT(i);                 % 1st and 2nd colums indicates TIME and AMPLITUDE values respectively!
        DisMat(i,2)= RPksA(i);
    end
    for i=1:c-1                               % 3rd column indicates the DIFFERENCE between (i+1)'th-i'th elements
        DisMat(i+1,3)= D(i);
    end

    SDisMat  =sortrows(DisMat,3);            % Sorting DisMat in order to find the smallest time interval=S1 
    s1(1,1) = SDisMat(c,1);                  % Assigning the first element
    
    k = find(DisMat(:,1)==s1(1,1));          % First element's row indice. LABEL OF THE S1
    a=k; k1=k; gk=k; r=1;                    % gk = global "k"
    
    if gk>1
        
    for i=1:ceil(a/2)
            
        s1(i,1)=DisMat(k,1);                  % TIME LABELS OF S1
        s1(i,2)=DisMat(k,2);                  % AMPLITUDE LABELS OF S1
        k=k-2;
    end
    for j=1:floor((c-a)/2)
        i=i+1;
        s1(i,1)=DisMat(k1+2,1);               % TIME
        s1(i,2)=DisMat(k1+2,2);               % AMPLITUDE
        k1=k1+2;
    end
s1=sortrows(s1,1);                            % ****** END OF S1 ASSIGNMENT ******
 
    b=gk; k2=gk; i=1;
    for j=1:floor(b/2)
        s2(i,1)=DisMat(gk-1,1);               % TIME LABELS OF S2
        s2(i,2)=DisMat(gk-1,2);               % AMPLITUDE LABELS OF S2
        gk=gk-2;
        i=i+1;
    end
    for j=1:ceil((c-b)/2)
        
        s2(i,1)=DisMat(k2+1,1);               % TIME
        s2(i,2)=DisMat(k2+1,2);               % AMPLITUDE
        k2=k2+2;
        i=i+1;
    end
s2=sortrows(s2,1);                     % ****** END OF S2 ASSIGNMENT ******

    else 
        s1(1,1) = SDisMat(c,1); s1(1,2) = SDisMat(c,2);
        s2(1,1) = SDisMat(c,1); s2(1,2) = SDisMat(c,2);
    end


clear i j DisMat SDisMat T A D k gk k1 k2 r  c r1 c1 r2 c2; % s1 s2


% (EXTRACTING FEATURES)
%-------------------------------------------------------------------------- 
%**************************************************************************
% FEATURE 1-2: MEAN AND STD OF TIME INTERVAL BETWEEN S1-S2
    
    [r1,c1]=size(s1);
    [r2,c2]=size(s2);

    if s1(1)<s2(1)                      
          for i=1:r2
            t12(i)=abs(s1(i)-s2(i));
          end
       else if r1==1
            t12=0.45;
       else
          for i=1:r2-1
            t12(i)=abs(s1(i)-s2(i+1));
          end
       end
    end
    STD12   = std(t12);  % F1 std of time interval of s1 to s2
    T12     = mean(t12); % F2 Mean value of time interval of s1 to s2
     
clear t12 r1 r2 c1 c2 

%**************************************************************************  
% FEATURE 3-4: "T21(k)" TIME INTERVAL BETWEEN S2-S1

    [r1,c1]=size(s1);
    [r2,c2]=size(s2);
    
    if s2(1)<s1(1)                      
        for i=1:r1
        t21(i)=abs(s2(i)-s1(i));
        end
    else if r2==1
        t21=0.45;
    else
        for i=1:r1-1
        t21(i)=abs(s2(i)-s1(i+1));
        end
    end
    end
    STD21   = std(t21);     % F3 standart deviation of time interval of s2 to s2
    T21     = mean(t21);    % F4 Mean value of time interval of s2 to s1
   
clear t12 t21 r1 r2 c1 c2

%**************************************************************************
% FEATURE "F3_MT12(k) & F3_MT21(k)" MEAN OF S1&S2/MEAN OF TOTAL S1&S2 

%MT12=mean(T12);    MT21=mean(T21);    ST12=std(STD12);     ST21=std(STD21);
%F3_MT12=T12./MT12;
%F3_MT21=T21./MT21;
%**************************************************************************
% FEATURE "F4_STD12(k)& F4_STD21(k)" STANDART DEVIATION OF S1&S2 OVER WHOLE STANDART DEVIATION
 
%F4_STD12=STD12./ST12;
%F4_STD21=STD21./ST21;

%**************************************************************************
% FEATURE 5: "F5_RejectedPeakRate
[r1,c1] = size(pidx);
[r2,c2] = size(RPksT);

Rejected_Peak_Rate = c2/r1; % F5
clear r1 c1 r2 c2;
%**************************************************************************
% FEATURE 8: "F8_AmplitudeRate(k)"

Amplitude_Rate = mean(pks)/mean(RPksA); % F6


