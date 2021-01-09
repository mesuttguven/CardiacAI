function [ CC, FBE, frames ] = mfcc( speech, fs, Tw, Ts, alpha, window, R, M, N, L )


    if( max(abs(speech))<=1 ), speech = speech * 2^15; end;

    Nw = round( 1E-3*Tw*fs );   
    Ns = round( 1E-3*Ts*fs );    

    nfft = 2^nextpow2( Nw );     
    K = nfft/2+1;               

    hz2mel = @( hz )( 1127*log(1+hz/700) );     
    mel2hz = @( mel )( 700*exp(mel/1127)-700 ); 

    dctm = @( N, M )( sqrt(2.0/M) * cos( repmat([0:N-1].',1,M) ...
                                       .* repmat(pi*([1:M]-0.5)/M,N,1) ) );

    ceplifter = @( N, L )( 1+0.5*L*sin(pi*[0:N-1]/L) );

    speech = filter( [1 -alpha], 1, speech ); 
    frames = speech;
    MAG = abs( fft(frames,nfft,1) ); 
    H = trifbank( M, K, R, fs, hz2mel, mel2hz ); 
    FBE = H * MAG(1:K,:); 
    DCT = dctm( N, M );
    CC =  DCT * log( FBE );
    lifter = ceplifter( N, L );
    CC = diag( lifter ) * CC; 

