
//timer1 will interrupt when run full scale 16 bit (use TOV1 interrupt)
//Prescale = 1;
// interrupt frequency = 16000000/65536
#define CIRCULAR_BUFFER_INT_SAFE
#define BUFFER_SIZE 1500
#include <CircularBuffer.h>
CircularBuffer<volatile float, 10> buffer;
//#define CIRCULAR_BUFFER_XS 256

const byte clkMeasuredPin = 2;
enum STATE {RUN,STOP,UNCHANGE};
STATE ARDUINO_STATE = RUN;
float data[BUFFER_SIZE];
int index = 0;
void setup()
{
  //init Serial communication to PC
  Serial.begin(115200);
 
  //---set up timer 1------------------------------------------
  noInterrupts();//Stop interrrupt;

  //set timer1 interrupt at 16MhZ
  TCCR1A = 0;// set entire TCCR1A register to 0
  TCCR1B = 0;// same for TCCR1B
  TCNT1 = 0;//initialize counter value to 0

  //turn on Normal mode (mode 0)
  //, no need to do any thing as all value is 0
  TCCR1A |= (0 << WGM11) | (0 << WGM10);
  
  //Set prescaler is 1
  TCCR1B |= (1 << CS10) | (0 << WGM12) | (0 << WGM13);
  
  //Enable timer overflow interrupt TOV1
  TIMSK1 |= (1 << TOIE1);
  
  //allow interrupt
  sei();
  
  
  //setup hardware interrupt
  //if the internal pull-up resistor for pin 2 
  //(interrupt 0) is enabled by adding the line:
  pinMode(clkMeasuredPin, INPUT_PULLUP);
  
  attachInterrupt(digitalPinToInterrupt(clkMeasuredPin), CLK_DECT, RISING);
}

//declare a counter to count every time timer is overflow
unsigned long counter = 0;

ISR(TIMER1_OVF_vect)
{
  counter += 1;
}

char oldSREG; //store old config register
float period = 0; //amended to hold more than 65536 (could be nearly double this)
unsigned int current_TCNT1,previous_TCNT1=0; // store value of timer 1 

//callback function when edge is detected
void CLK_DECT()
{
  //need to disable interrupt while reading timer01 value, store config register in a oldSRED
  oldSREG = SREG;
  
  //disable interrupt
  noInterrupts();

  //read current value of timer01 - 16bit
  current_TCNT1 = TCNT1;

  //push back config register
  SREG = oldSREG;
  
  //calculate clock input period, comment this part if you wanna calculate the period on server.

  //1.0076 is an experiement value to calibrate the clock
  //period = (counter*65536.0 + current_TCNT1 - previous_TCNT1)/16e6;
  period = (counter*65536.0 + current_TCNT1 - previous_TCNT1);//16e6;
  
  //if (ARDUINO_STATE == RUN)
  {
  /*  Serial.print(timer01_value);  Serial.print(",");
    Serial.print(counter);Serial.print(",");
    Serial.println(1/period,5);*/
  }

  //push value in ringbuffer
//    buffer.push(current_TCNT1);
//    buffer.push(counter);
    
    // push frequency into buffer
    //buffer.push(1.001/period);
    buffer.push(period);

  // store current value of timer01 to previous_TCNT1
  previous_TCNT1 = current_TCNT1;

  //reset counter of timer interrupt.
  counter = 0;
}



  //declare variables for upload data to 
//unsigned short dataSize;
String valueString = "";
char str[20];

//unsigned long delayStep = 1000000;
//bool en_delayStep = 1;
void loop() {

//  if (delayStep ==0)
//  {
//     analogWrite(ENABLE_MOTOR_PIN,64);
//     en_delayStep = 0;
//  }
//  if (en_delayStep)  delayStep --;
  // put your main code here, to run repeatedly:
  //  Serial.println(counter);
  //  delay(500);
    //if (!buffer.isEmpty())
    //{
    //    Serial.print(buffer.shift());
    //    Serial.print(",");
    //}
    if (index==BUFFER_SIZE)
    {
      index =0;
        cli();
      for(int i=1;i<=BUFFER_SIZE-1;i++)
      {
      
        Serial.println(1.001*16e6/data[i],2);
       delay(100);
      }
          
    }
    if (!buffer.isEmpty())
    {
     /* dtostrf(buffer.shift(), 4, 6, str);  //4 is mininum width, 6 is precision
      valueString = str;
      Serial.println(valueString);*/
      
      data[index] = buffer.shift();
      index++;       
    }
}
void serialEvent() 
{
  while (Serial.available()) 
  {
    // get the new byte:
    char inChar = (char)Serial.read();
    //Serial.println(inChar);

    // add it to the inputString:
    //inputString += inChar;

    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == 'S')
    {
      //stringComplete = true;
      Serial.println("stop now !");
      ARDUINO_STATE = STOP;
    }
    if (inChar == 'R')
    {
      //stringComplete = true;
      ARDUINO_STATE = RUN;
    }
  }
}
