#concepts 
Use a model of the system being measured, and to update the model as new measurements become available
2 phases:
	Predict/ Estimate
	Update
$$x_k = Ax_{k-1} $$
$$y_k=Hx_k $$
estimate $$(\hat{x_k}, \hat{y_k})\pm error$$ $$ x_k = Ax_{k-1} + n_p $$ -- Process Model
$$ y_k = Hx_k +n_m $$ --Measurement model

Kalman Filter is a state estimate which combines process and measurement models

$$ \hat{x_k} = x_k^p + K_k(y_k-\hat{y_k}) $$
K is the Kalman gain that we can tune to fit the $$\hat{x_k}\text{ to the }x_k $$ and it changes each iteration to better fit the model

Extended Kalman Filter - looks at non-linear dynamics/measurements
Unscented Kalman Filter - even better at more complex non-linear systems

