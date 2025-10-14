#paper
[[Magnetometer]] Fusion Motion Tracking
tracks orientation and location
magnetic north is primary anchor compared to gravity 
MUSE creates system for 3d orientation using 5 equations
uses gyroscope and turns local to global reference change
Gyroscope and magnetometer have different noise properties
recalculates when motion pauses using accelerometer
limitations include issues with rotation around north axis, needs to start with static position for calibration, magnetic field interference is major issue

CDF plot important to learn how to read
0.5 on CDF axis is median of errors, aka half of errors will be that or less.
Main part is the bend which is called the knee, the closer to the top left corner the better