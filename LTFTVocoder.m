function [ out ] = LTFTVocoder( s,dilate,osci,max_supp,min_supp,range,overlap,alpha,quadrature_method)
%Computes the quasi Monte-Carlo or Monte-Carlo integer-time-stretching phase vocoder, based on the 
%localizing time-frequency transform.
%
%
%Output variable:
%
%out= one channel real valued audio signal.
%
%
%Input variables:
%
%s= the input single channel signal as a column vector of floats.
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

if ~ exist ( 'quadrature_method' , 'var' ) %if third parameter does not exist, so default is quasi Monte Carlo:    
      quadrature_method = 'QMC';
end

%Prepare the signal:
s=double(s)';
N=numel(s);
M=N*dilate*overlap; %the number of atoms in the method

if strcmp(quadrature_method,'MonteCarlo') %generate random sample points   
    g=rand(M,3);   %this is the sequence of 3D sample points:
                   %g=(times,frequencies,ranges)
else %generate the quasi-random sample points
    rng default
    p = haltonset(3);
    p = scramble(p,'RR2');
    g = net(p,M);  %this is the sequence of 3D sample points:
                   %g=(times,frequencies,ranges)
end
               

p = gcp; %get parallel pool for parallel computing in CPU
Workers=2*p.NumWorkers; %number of workers is twice the number of CPU cores
out=double(zeros(dilate*N,Workers)); %each worker builds a separate output signal, and at the end they are added up
Msmall=floor(M/Workers); %number of samples for each worker
G=double(zeros(Msmall,3,Workers)); %the samples that each workers uses
for j=0:(Workers-1)
    G(:,:,j+1)=g(j*Msmall +(1:Msmall),:);
end
parfor j=0:(Workers-1)
    out(:,j+1) = QRV(G(:,:,j+1),N,floor(M/Workers),s,dilate,osci,max_supp,min_supp,range,alpha); % the LTFT phase vocoder computation
end

out=sum(out,2); % sums up together the outputs of the separate workers
out=out/max(abs(real(out)))'; % signal normalization
end
