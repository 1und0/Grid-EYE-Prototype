import oscP5.*;
import netP5.*;
import cc.arduino.*;
import processing.serial.*;

OscP5 oscP5;
Serial port;

/* Global Variables */
NetAddress myBroadcastLocation;
float[][] temp;
float[][] filtertemp;
float[][] finaltemp;
boolean bgfilter = false;
boolean hpfilter = false;
PShape square;
PFont font;

float minCel = 900.0;
float maxCel = -900.0;
int grtValue;

/***************************************************************************
* Initialize processing sketch
*/
void setup() {
    size(500, 500, P2D);
    frameRate(25);
    setup_osc();
    setup_serial();
    setup_visualisation();
}

/*
* Initialize osc connection
*/
void setup_osc() {
  oscP5 = new OscP5(this,5001);
  myBroadcastLocation = new NetAddress("127.0.0.1",5000);
}

/*
* Initialize serial connection 
* Linux: "/dev/ttyUSBx"
* Mac: Serial.list()[x]
*/
void setup_serial() {
  port = new Serial(this, Serial.list()[1], 115200);
  port.bufferUntil(';');
  temp = new float[8][8];
  filtertemp = new float[8][8];
  finaltemp = new float[8][8];
}

/*
* Initialize fonts and froms for draw function
*/
void setup_visualisation() {
  font = createFont("Arial",14,true);
  textFont(font,14); 
  square = createShape(RECT, 0, 0, 50, 50);
  square.setFill(color(255, 255, 255));
  square.setStroke(false);
}

/***************************************************************************
* Draw function
*/
void draw () {
  background(0,0,0);
  text(String.format("%.2f",minCel), 120,40);
  text(String.format("%.2f",maxCel), 180,40);
  for(int y=0; y<8; y++) {
    for(int x=0; x<8; x++) {
       
       float c = map(finaltemp[x][y], 0, 1, 0.0, 255.0);
       square.setFill(color(int(c),0,0)); 
       if (grtValue == 1) {
         square.setFill(color(0,int(c),0)); 
       }
       shape(square, 51*(x+1)+1, 51*(y+1)+1);
       text(String.format("%.2f",finaltemp[x][y]), 10+51*(x+1),40+51*(y+1));
     }
   }
}

/***************************************************************************
* Events triggered by serial input
*/
void serialEvent(Serial port) {
  readSensorData(port);  
  filter(temp);
  sentOscMessage();  
}

/*
* Read and process sensor data from serial
*/
void readSensorData(Serial port) {
  String data = "";
  String[] list;
  minCel = 900.0;
  maxCel = -900.0;
  data = port.readStringUntil(';');
  data = data.substring(10, data.length() - 1);
  list = split(data, ",");

  int z=63;
  for(int x=0; x<8; x++){
    for(int y=0; y<8; y++){
      if (float(list[z]) > maxCel) {
        maxCel = float(list[z])+0.5;
      }
      if (float(list[z]) < minCel) {
        minCel = float(list[z])-0.5;
      }
      temp[y][x] = float(list[z]);
      z--;
    }
  }
}

/*
* Applies activated filter to matrix and reduces output 
* to 0 and 1 
*/
void filter(float[][] temp){
   
   // Highpass filter 30%
   float reference = (Math.abs(maxCel)-Math.abs(maxCel-minCel)*0.6);
   println(reference);
   if (hpfilter) {
     for(int x=0; x<8; x++){
       for(int y=0; y<8; y++){
         if (temp[x][y] < reference){
           finaltemp[x][y] = 0.0;
         }
         else finaltemp[x][y] = 1.0;
       }
     }
   } else
   
   // Background filter deviation 3
   if (bgfilter){
     for(int x=0; x<8; x++){
       for(int y=0; y<8; y++){
         //if (temp[x][y] < reference){
         if (temp[x][y] < filtertemp[x][y]){
           finaltemp[x][y] = 0.0;
         }
         else finaltemp[x][y] = 1.0;
       }
     }
   }   
   
   // No filter
   else {
     for(int x=0; x<8; x++){
       for(int y=0; y<8; y++){
         finaltemp[x][y] = temp[x][y];
       }
     }
   }
}

/*
* Sends datasets to GRT via osc message
*/
void sentOscMessage() {
  OscMessage myOscMessage = new OscMessage("/Data");
  for (int i=0; i<8; i++){
    for (int j=0; j<8; j++){
      myOscMessage.add(finaltemp[i][j]);
    }
  }
  oscP5.send(myOscMessage, myBroadcastLocation);
}

/***************************************************************************
* Event triggert by osc reception
*/
void oscEvent(OscMessage osc) {
  if (osc.checkAddrPattern("/Prediction") == true) {
    grtValue = osc.get(0).intValue();
  }
}

/***************************************************************************
* Key events
*/
void keyPressed(){
  switch(key){
    case 'h': 
          if(hpfilter == false) {
            hpfilter = true; 
          } else {
            hpfilter = false; 
          }  
          break;
    case 'b': 
          if(bgfilter == false) {
            for(int x=0; x<8; x++){
              for(int y=0; y<8; y++){
                filtertemp[x][y] = temp[x][y]+3;
              }
            }
            bgfilter = true; 
          } else {
            bgfilter = false; 
          }
          break; 
  }
}