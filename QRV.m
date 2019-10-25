function [out] = QRV(g,N,M,sR,dilate,osci,max_supp,min_supp,range,alpha)
%Computes the quasi Monte-Carlo or Monte-Carlo integer-time-stretching phase vocoder, based on the 
%localizing time-frequency transform.
%
%Wrapped by QuasiRandomVocoder.m
%
%Output variable:
%
%out= one channel real valued audio signal.
%
%
%Input variables:
%
%g= the quadrature points
%N=size of the signal
%M=number of samples
%sR= the input single channel real valued signal as a column vector of floats.
%dilate= the integer stretching amount.
%osci= the number of oscilation inside the wavelet atoms.
%max_supp= the uppoer bound on window time support.
%min_supp= the lower bound on window time support.
%range= determines the range of supports of the atoms. 
%       The basic support of each wavelet atom at frequency freq is
%       supp=1+osci/(freq/pi+50/N)
%       and this basic support is extended according to the range by
%       range*(1+1/range)*supp
%overlap=determines the number of atoms in the method. The number of atoms
%        is M=N*dilate*overlap.
%alpha: controls the distribution of supports. 
%       the greater alpha is, the more likely it is to pick small supports 
%quadrature_method: a string, if equal to 'MonteCarlo' the quadrature
%       points are random, else the quadrature points are quasi-random.


m=double(0);
n=double(0);
time=double(0);
freq=double(0);
supp=double(0);
t=double(0);
res=double(0);
K2=double(0);
normm=double(0);
xbot=double(0);
xtop=double(0);
coeffR=double(0); %for faster computations, all variables are decomposed to real and imaginary parts
coeffI=double(0);
r=double(0);
coRN=double(0);
coIN=double(0);
coRNout=double(0);
coINout=double(0);
coRNoutp=double(0);
coINoutp=double(0);
coeff2R=double(0);
coeff2I=double(0);
out=double(zeros(1,dilate*N));
outp=double(zeros(20,dilate*N));
winR=double(zeros(1,2*max_supp+1));
winI=double(zeros(1,2*max_supp+1));




for m=1:M
    time=g(m,1)*(N-1); %time of the atom
    freq=pi*g(m,2); %frequency of the atom
    supp=min(1+osci/(freq/pi+50/N),max_supp); %support of the atom
    supp=range*(g(m,3)^alpha+1/range)*supp;
    supp=min(supp,max_supp);
    supp=max(supp,min_supp);
    t=round(time);
    res=time-t;
    K2=floor(supp);
    
    %Hann window:
    normm=0;
    for n=-K2:K2 %window computation and its square norm
        winR(K2+n+1)=1+cos(pi*(n-res)/supp);
        normm=normm+winR(K2+n+1)*winR(K2+n+1);
        winI(K2+n+1)=winR(K2+n+1);
        winR(K2+n+1)=winR(K2+n+1)*cos(freq*(n-res));
        winI(K2+n+1)=winI(K2+n+1)*sin(freq*(n-res));
    end
    xbot=max([(t-K2), 0]);
    xtop=min([(t+K2), (N-1)]);
    coeffR=0;
    coeffI=0;
    for n=xbot:xtop %coefficient computation
        coeffR=coeffR+sR(1+n)*winR(1+K2-t+n);
        coeffI=coeffI-sR(1+n)*winI(1+K2-t+n);
    end
    r=sqrt(coeffR^2+coeffI^2);
    coRN=coeffR/r;
    coIN=coeffI/r;
    coRNout=1;
    coINout=1;
    for d=1:dilate % phase correction
        coRNoutp=coRNout;
        coINoutp=coINout;
        coRNout=coRNoutp*coRN -coINoutp*coIN;
        coINout=coRNoutp*coIN +coINoutp*coRN;
    end
    coeff2R=r*coRNout; %phase correcting the real part of the coefficient
    coeff2I=r*coINout; %phase correcting the imaginary part of the coefficient
    xbot=max([(dilate*t-K2), 0]);
    xtop=min([(dilate*t+K2), (dilate*N-1)]);
    for n=xbot:xtop % addin the atom to the output signal
        out(1+n)=out(1+n)+coeff2R*winR(1+K2-dilate*t+n)/normm-coeff2I*winI(1+K2-dilate*t+n)/normm;
    end
end



end

