 /*
 import processing.video.*;
class houghCam{
 
 Capture cam;
 PImage img;
 
 void settings(){
    size(640,480); 
 }
 void setup(){
  String[] cameras = Capture.list();
  if(cameras.length == 0){
    println("No camera available");
    exit();
  }else{
     println("Available cameras:");
     for(int i = 0; i <cameras.length; i++){
        println(cameras[i]); 
     }
     cam = new Capture(this);
     cam.start();
  }
 }
  void draw(){
     if(cam.available() == true){
         cam.read(); 
     }
     img = cam.get();
     image(img,0,0);
    
  }
 }
 */
  
  