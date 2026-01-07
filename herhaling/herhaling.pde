size(1000,400);
int groote=40;
int afstand=60;
for(int i=1; i<11; i++){
  if(i==2||i==4||i==6||i==8||i==10){fill(255,0,0);}
  else{fill(0,0,255);}
  ellipse(i*afstand,afstand/2,groote,groote);
 
}
