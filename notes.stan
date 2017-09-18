
// Useful notes:
// Can impose summing up constraints with "transformed parameters" block.  See p. 135 ff.




//Model 1.

data{
  int<lower = 0> N;          // does this need Lower = 0?  
  vector[N] x;               // declares vector of length N 
  int<lower=0,upper=1> y[N]; // Declares input vector of length N with possible values 0, 1

}
parameters{
  real beta;

}
model{

}