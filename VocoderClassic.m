function [ DAFx_out ] = VocoderClassic( s , dilate,n1,s_win )
%Based on code from the book DAFX: Digital Audio Effects, Scond edition, by Udo Zolzer.
%Computes integer dilation phase vocoder based on the short time Fourier transform
%s=column signal
%dilate=integet time dilation factor
%n1=analysis step size
%s_win=window time support
n2=n1*dilate;
w1 = hanning(s_win, 'periodic'); % analysis window
w2 = w1; % synthesis window
L = length(s);
s = [zeros(s_win, 1); s; ...
    zeros(s_win-mod(L,n1),1)] / max(abs(s));
DAFx_out = zeros(s_win+ceil(length(s)*dilate),1);
omega = 2*pi*n1*[0:s_win-1]'/s_win;
omega=omega*1; 
phi0 = zeros(s_win,1);
psi = zeros(s_win,1);
pin = 0;
pout = 0;
pend = length(s)-s_win;
while pin<pend
    grain = s(pin+1:pin+s_win).* w1;
    f = fft(fftshift(grain));
    r = abs(f);
    phi = angle(f);
    ft=exp(1i*dilate*phi).*r;
    grain = fftshift(real(ifft(ft))).*w2;
    DAFx_out(pout+1:pout+s_win) = ...
    DAFx_out(pout+1:pout+s_win) + grain;
    pin = pin + n1;
    pout = pout + n2;
end
DAFx_out = DAFx_out(s_win+1:length(DAFx_out))/max(abs(DAFx_out));

end

