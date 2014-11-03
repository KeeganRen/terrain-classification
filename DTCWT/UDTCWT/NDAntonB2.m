function [af, sf] = NDAntonB2


a0 = [
   0
   0.02674875741081
  -0.01686411844287
  -0.07822326652899
   0.26686411844288
   0.60294901823636
   0.26686411844287
  -0.07822326652899
  -0.01686411844287
   0.02674875741081
   0
   0	
];

a1 = [
   0	
   0
   0.04563588155712
  -0.02877176311425
  -0.29563588155712
   0.55754352622850
  -0.29563588155713
  -0.02877176311425
   0.04563588155712
   0
   0
   0	
];

s0 = [
   0	
   0
   0
  -0.04563588155712
  -0.02877176311425
   0.29563588155712
   0.55754352622850
   0.29563588155713
  -0.02877176311425
  -0.04563588155712
   0
   0	
];

s1 = [
   0
   0	
   0.02674875741081
   0.01686411844287
  -0.07822326652899
  -0.26686411844288
   0.60294901823636
  -0.26686411844287
  -0.07822326652899
   0.01686411844287
   0.02674875741081
   0
    	
];


s0 = 2*s0;
s1 = 2*s1;

aa0 = [
   0
   0
   0.02674875741081
  -0.01686411844287
  -0.07822326652899
   0.26686411844288
   0.60294901823636
   0.26686411844287
  -0.07822326652899
  -0.01686411844287
   0.02674875741081
   0
];

aa1 = [
   0 
   0
   0
   0.04563588155712
  -0.02877176311425
  -0.29563588155712
   0.55754352622850
  -0.29563588155713
  -0.02877176311425
   0.04563588155712
   0
   0

];

ss0 = [
   0
   0
  -0.04563588155712
  -0.02877176311425
   0.29563588155712
   0.55754352622850
   0.29563588155713
  -0.02877176311425
  -0.04563588155712
   0
   0
   0
];

ss1 = [
    0
   0.02674875741081
   0.01686411844287
  -0.07822326652899
  -0.26686411844288
   0.60294901823636
  -0.26686411844287
  -0.07822326652899
   0.01686411844287
   0.02674875741081
   
0
0
];

ss0 = 2*ss0;
ss1 = 2*ss1;





af{1} = [a0 a1];af{1} = af{1}./sqrt(2);

sf{1} = [s0 s1];sf{1} = sf{1}./sqrt(2);

af{2} = [aa0 aa1];af{2} = af{2}./sqrt(2);

sf{2} = [ss0 ss1];sf{2} = sf{2}./sqrt(2);