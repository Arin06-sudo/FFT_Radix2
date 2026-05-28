               
module butterfly_unit(input signed[15:0] real1,complex1,
                      input signed[15:0]real2,complex2,                  
                      output signed[15:0] sumout_real,sumout_complex,
                                  subout_real,subout_complex);
   wire signed [16:0] real_sum,complex_sum;
   wire signed[16:0] real_sub,complex_sub;
   
   assign real_sum = $signed(real1) + $signed(real2);
   assign complex_sum = $signed(complex1) + $signed(complex2);
   assign real_sub = $signed(real1) - $signed(real2);
   assign complex_sub = $signed(complex1) - $signed(complex2);

   assign sumout_real = real_sum[16:1];
   assign sumout_complex = complex_sum[16:1];
   assign subout_real = real_sub[16:1];
   assign subout_complex = complex_sub[16:1]; 
                               

endmodule
