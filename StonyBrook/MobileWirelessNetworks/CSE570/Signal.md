#concepts 
any varying phenomenon which conveys info is a signal

We process signal data to extract info 

signal come in analog or digital
analog is generally continuous
digital is discrete 

periodic signal repeat after some time vs aperiodic/non-periodic

deterministic vs random signals
randomness may be because of noise from the sensor
signal-to-noise ratio = SNR 
Jitter noise
$${Signal}/{noise}$$
properties of a signal 
	frequency
		occurrences over time
		Hz
	amplitude
		max value of the signal
	phase
		angular orientation over time
		$$A*sin(\theta)=A*sin(2\pi ft)$$

Fourier Series - any function can be written as the sum of sinusoidal functions
Fourier transform is how to determine the coefficients
Break up signal over short time aka Windowing. you can Fourier transform each window
filtering - low pass allows low frequency and blocks high frequency
cocktail party problem - who are speaking at the same time
Blind source separation - how to separate different people voices from each other

smoothing which uses a low pass filter to remove jitter