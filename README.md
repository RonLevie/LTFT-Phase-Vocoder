# LTFT-Phase-Vocoder
The classical phase vocoder is based on the short-time-Fourie-transform (STFT) as the time-frequency representation. LTFT Phase Vocoder is based on a novel time-frequency representation called the localizing-time-frequency-transform (LTFT).

## The LTFT phase vocoder method
### The localizing-time-frequency-transform
The LTFT decomposes audio signals to a linear combination of simple instantaneous frequency atoms, that we call LTFT atoms. Each LTFT atom is specified by three parameters: *Time*, *Frequency*, and *Oscillations*. Each atom is a short bump in the time axis, centered about a certain time location called the *Time* of the atom, modulated by oscillations of a certain frequency called the *Frequency* of the atom. The *Oscillations* parameters determines how many oscillations there are in the atom. This means that the interval on which the atom is supported is proportional to *Oscillations/Frequency*. 

The LTFT representation is determined by two additional constants, *MaxSupport* and *MinSupport*. Any atom that is supported on a larger time interval than *MaxSupport*, or shorter time interval than *MinSupport*, is replaced by an atom of time support *MaxSupport* or *MinSupport* respectively.

Given a signal *s*, the LTFT of *s* is a function that assigns a complex number to each (*Time*, *Frequency*, *Oscillations*) triplet. This number, called the coefficient of the atom (*Time*, *Frequency*, *Oscillations*), quantifies “how much this atom is present in *s*”. 

Given a function *F* that assigns a complex number to each (*Time*, *Frequency*, *Oscillations*) triplet, the synthesis LTFT transform adds up all of the LTFT atoms (*Time*, *Frequency*, *Oscillations*)  with the corresponding coefficients *F*(*Time*, *Frequency*, *Oscillations*). This gives an audio signal  *s*with roughly *F* as the LTFT of *s*.


### LTFT phase vocoder
Given an input signal *s* and a positive integer *d*, the LTFT phase vocoder extracts the coefficients of all atoms *F*(*Time*, *Frequency*, *Oscillations*). Then, *F* is dilated along the *Time* direction by *F*(*d Time*, *Frequency*, *Oscillations*), and its complex phase are modified, to obtain a dilated version *H* of *F* (see the paper for more details). Last, *H* is synthesized to an output signal. This output signal is a time-dilated version of *s* that preserves the pitch of *s*. 

## Examples

