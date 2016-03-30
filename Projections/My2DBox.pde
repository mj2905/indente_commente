class My2DBox {
 My2DPoint[] s;
 
 My2DBox(My2DPoint[] s) {
  this.s = s; 
 }
 
 void render() {
          strokeWeight(3);
          //As in the drawing :
   //First green
   for(int i=0; i <= 3; ++i) {
         stroke(0,255,0);
       lineBetPoints(s[4 + i],s[4 + ((i+1)%4)]);
   }
   //Then blue
   for(int i=0; i <= 3; ++i) {
         stroke(0,0,255);
       lineBetPoints(s[i],s[(i+4)]);
   }
   //And finally red
   for(int i=0; i <= 3; ++i) {
         stroke(255,0,0);
       lineBetPoints(s[i],s[(i+1)%4]);
   }
   
   //We could have used the same for loop for the 3 kind of lines, but then we wouldn't have had the same drawing as in the example.
 }
 
 //Helper function, to abtract the line with two points
 private void lineBetPoints(My2DPoint p1, My2DPoint p2) {
   line(p1.x, p1.y, p2.x, p2.y);
 }

}