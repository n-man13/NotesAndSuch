[[Sensors]] Made up of [[Accelerometer]], [[Gyroscope]], and [[Magnetometer]] 

Attitude or Orientation mean the directionality in 3d space
Pitch, Roll, and Yaw (Heading)

IMU can use all 3 sensors to track the orientation.

all of these measurements are in the local/body reference frame

most common reference frames are local/body and inertial/global frame

[cos(\theta) -sin(\theta)
sin(\theta) cos(\theta)] -- counter clockwise
[cos(\theta) sin(\theta)
-sin(\theta) cos(\theta)] -- clockwise

$$
R^(v1)_1 (\theta)=
$$

IMU data to 3d trajectory by using a motion tracking algorithm

turning accelerometer data to distance is noisy, because of gravity and the double integration
also all data in local coordinate frame - needs to be transformed into global coordinate frame

as per [[MUSE]], accel and gyro is not enough to get full 3d orientation, needs magnetometer also

Muse uses a Complementary Filter to merge the sensor data to get better data
Gyro gets high pass filter while accel gets lpf
HPF lets high frequency pass and blocks low frequency through
LPF lets low frequency pass and blocks high frequency through