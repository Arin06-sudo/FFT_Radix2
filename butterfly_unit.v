               
module butterfly_unit(input signed[15:0] real1,complex1,
                      input signed[15:0]real2,complex2,                  
                      output signed[15:0] sumout_real,sumout_complex,
                                  subout_real,subout_complex);
   assign sumout_real = (real1 + real2)>>1;   
   assign sumout_complex = (complex1+complex2)>>1;
   assign subout_real = (real1-real2)>>1;
   assign subout_complex = (complex1-complex2)>>1;
                               



endmodule

