# LTFT-Phase-Vocoder
LTFT-Phase-Vocoder is an audio effect that slows down an audio signal without dilating its frequency content or pitch.
The classical phase vocoder is based on the short-time-Fourie-transform (STFT) as the time-frequency representation of the phase vocoder. LTFT Phase Vocoder is based on a novel time-frequency representation called the localizing-time-frequency-transform (LTFT).
For more information see the papers :

[Ron Levie, Haim Avron. Randomized Signal Processing with Continuous Frames. 2018.](https://arxiv.org/abs/1808.08810)

[Ron Levie, Haim Avron. Randomized Continuous Frames in Time-Frequency Analysis. 2020.](https://arxiv.org/abs/2009.10525)

[Ron Levie, Haim Avron, Gitta Kutyniok. Quasi Monte Carlo Time-Frequency Analysis. 2020.](https://arxiv.org/abs/2011.02025)

## The LTFT phase vocoder method
### The localizing-time-frequency-transform
The LTFT decomposes audio signals to a linear combination of simple instantaneous frequency atoms, that we call LTFT atoms. Each LTFT atom is specified by three parameters: *Time*, *Frequency*, and *Oscillations*. Each atom is a short bump in the time axis, centered about a certain time location called the *Time* of the atom, modulated by oscillations at a certain frequency called the *Frequency* of the atom. The *Oscillations* parameters determines the number of oscillations in the atom. This means that the interval on which the atom is supported is proportional to *Oscillations/Frequency*. 

The LTFT representation is determined by two additional constants, *MaxSupport* and *MinSupport*. Any atom that is supported on a larger time interval than *MaxSupport*, or shorter time interval than *MinSupport*, is replaced by an atom of time support *MaxSupport* or *MinSupport* respectively.

Given a signal *s*, the LTFT of *s* is a function that assigns a complex number to each (*Time*, *Frequency*, *Oscillations*) triplet. This number, called the coefficient of the atom (*Time*, *Frequency*, *Oscillations*), quantifies “how much this atom is present in *s*”. 

Given a function *F* that assigns a complex number to each (*Time*, *Frequency*, *Oscillations*) triplet, the synthesis LTFT transform adds up all of the LTFT atoms (*Time*, *Frequency*, *Oscillations*)  with the corresponding coefficients *F*(*Time*, *Frequency*, *Oscillations*). This gives an audio signal  *s* with roughly *F* as the LTFT of *s*.

LTFT has an advantage over classical time-frequency representations like the short-time-Fourier-transform (STFT), since the feature space of LTFT is 3D, and the feature space of STFT is 2D. The additional axis of LTFT increases the expressive capacity of the atom system, improving methods like phase vocoder. To overcome the increased computational cost entailed by the third axis, LTFT phase vocoder is implemented via a Monte Carlo or quasi Monte Carlo method.


### LTFT phase vocoder
Given an input signal *s* and a positive integer *d*, the LTFT phase vocoder extracts the coefficients of all atoms *F*(*Time*, *Frequency*, *Oscillations*). Then, *F* is dilated along the *Time* direction by *F*(*d Time*, *Frequency*, *Oscillations*), and its complex phases are modified, to obtain a dilated version *H* of *F* (see the paper for more details). Last, *H* is synthesized to an output signal. This output signal is a time-dilated version of *s* that preserves the pitch of *s*. 

Instead of considering the 3D space of all LTFT atoms, the LTFT phase vocoder method is implemented via a Monte-Carlo or quasi Monte-Carlo method, using only a random or quasi random set of LTFT atoms. The number of random atoms needed for high fidelity outputs is proportional to the number of time samples, or resolution, of the input signal.

LTFT phase vocoder is beneficial for processing polyphonic audio signals, since its 3D feature space is well equipped for representing a range of audio features, from transient events to harmonic features.

## Usage
### Usage of LTFT phase vocoder
```
out = LTFTVocoder(s,dilate,osci,max_supp,min_supp,range,overlap,alpha,quadrature_method)
```
Computes the quasi Monte-Carlo or Monte-Carlo integer time stretching phase vocoder, based on the localizing time-frequency transform.
#### Output variable

**out**: one channel real valued audio signal.

#### Input variables
**s**: the input single channel real valued signal as a column vector.

**dilate**: the integer stretching amount.

**osci**: the number of oscillations inside the wavelet atoms.

**max_supp**: the upper bound on window time support.

**min_supp**: the lower bound on window time support.

**range**: determines the range of supports of the atoms.  The basic support of each atom at frequency **freq** is **supp=1+osci/(freq/pi+50/N)** where **N** is the number of time samples of the signal **s**. This basic support is extended according to **range** to the support **range0 (1+1/range0)supp** where **range0** is sampled randomly/quasi-randomly between 0 and **range**.

**overlap**: determines the number of atoms in the method. The number of atoms is **M=N dilate overlap**.

**alpha**: controls the distribution of supports. The greater **alpha** is, the more likely it is to pick small supports.

**quadrature_method**: a string, if equal to 'MonteCarlo' the quadrature points are random, else the quadrature points are quasi-random.

### Usage of classical phase vocoder
For comparison with the classical integer time dilation phase vocoder, based on the STFT, use
```
DAFx_out = VocoderClassic(s,dilate,n,s_win)
```
Based on code from the book [Udo Zolzer. *DAFX: Digital Audio Effects, Second edition*. Wiley 2011](https://onlinelibrary.wiley.com/doi/book/10.1002/9781119991298).

**s**: one channel column signal.

**dilate**: integet time dilation factor.

**n**: analysis step size (lower **n** means more overlap between the windows).

**s_win**: window time support.

## Audio examples
To showcase the LTFT phase vocoder, we consider outtakes from songs by the power metal band [DragonForce](https://en.wikipedia.org/wiki/DragonForce). The overall sound of the band, and specifically the electric guitars with distortion, together with the bass guitar, lyrics, and fast paced drumming, constitutes highly polyphonic audio signals. LTFT phase vocoder can accommodate the different audio features simultaneously via the *oscillation* axis. Moreover, since LTFT is based on wavelet atoms, which are more localized in time than STFT atoms, [phasiness](https://www.researchgate.net/publication/3714372_Phase-vocoder_about_this_phasiness_business) is alleviated with respect to classical phase vocoder.   

We first consider an outtake from the iconic song [Through the Fire and Flames](https://www.youtube.com/watch?v=0jgrCKhxE1s).

[Audio: Through the Fire and Flames extract](/Dragon1.mp4)

We slow down this audio signal by 5.

We compute the LTFT phase vocoder
```
[DD FDD]=audioread('Dragon1.mp4');
Dx5LTFT(:,1) = LTFTVocoder(DD(:,1),5,15,2000,60,15,6,1.5);
Dx5LTFT(:,2) = LTFTVocoder(DD(:,2),5,15,2000,60,15,6,1.5);
audiowrite('Dx5LTFT.mp4',Dx5LTFT,FDD);
```
The resulting audio file: [Dx5LTFT.mp4](/Dx5LTFT.mp4)

To compare with the STFT phase vocoder, we compute
```
Dx5STFT(:,1)  = VocoderClassic(DD(:,1),5,5,2000);
Dx5STFT(:,1)  = VocoderClassic(DD(:,2),5,5,2000);
audiowrite('Dx5STFT.mp4',Dx5STFT,FDD);
```
The resulting audio file: [Dx5STFT.mp4](/Dx5STFT.mp4)

We note that by trial and error on the STFT pahse vocoder we found that a window size of 2000 samples gives a good balance between capturing the timber of the guitars and vocals, and avoiding as much phasiness as possible. The LTFT phase vocoder is less sensitive to parameter choice.

We then consider an extract from the song [Ashes of the Dawn](https://www.youtube.com/watch?v=DFeBkHJUZDg).

[Audio: Ashes of the Dawn extract](/Dragon2.mp4)

We slow down this audio signal by 5.

We compute the LTFT phase vocoder
```
[DD FDD]=audioread('Dragon2.mp4');
D2x5LTFT(:,1) = LTFTVocoder(DD(:,1),5,15,2000,60,15,6,1.5);
D2x5LTFT(:,2) = LTFTVocoder(DD(:,2),5,15,2000,60,15,6,1.5);
audiowrite('D2x5LTFT.mp4',D2x5LTFT,FDD);
```
The resulting audio file: [D2x5LTFT.mp4](/D2x5LTFT.mp4).

To compare with the STFT phase vocoder, we compute
```
D2x5STFT(:,1)  = VocoderClassic(DD(:,1),5,5,1500);
D2x5STFT(:,1)  = VocoderClassic(DD(:,2),5,5,1500);
audiowrite('D2x5STFT.mp4',D2x5STFT,FDD);
```
The resulting audio file: [D2x5STFT.mp4](/D2x5STFT.mp4).

Again, the window size 1500 for the STFT pahse vocoder was found by trial and error. In this example the LTFT phase vocoder is less aflicted by phasiness artifacts. Moreover, the drum hits in the LTFT method are better isolated.

We last consider an extract from In the Hall of the Mountain King, by Edvard Grieg.

[Audio: In the Hall](/Grieg.mp4)

We slow down this audio signal by 3.

We compute the LTFT phase vocoder
```
[DD FDD]=audioread('Grieg.mp4');
Gx3LTFT(:,1) = LTFTVocoder(DD(:,1),3,15,2000,60,15,6,1.5);
Gx3LTFT(:,2) = LTFTVocoder(DD(:,2),3,15,2000,60,15,6,1.5);
audiowrite('Gx3LTFT.mp4',Gx3LTFT,FDD);
```
The resulting audio file: [Gx3LTFT.mp4](/Gx3LTFT.mp4).

To compare with the STFT phase vocoder, we compute
```
Gx3STFT(:,1)  = VocoderClassic(DD(:,1),3,5,2000);
Gx3STFT(:,1)  = VocoderClassic(DD(:,2),3,5,2000);
audiowrite('Gx3STFT.mp4',Gx3STFT,FDD);
```
The resulting audio file: [Gx3STFT.mp4](/Gx3STFT.mp4).


