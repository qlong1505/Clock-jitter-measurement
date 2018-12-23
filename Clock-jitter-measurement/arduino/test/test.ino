/*
This test will send to serial two columns of timestamp and logic on every 1 second.
Author: qlong1505@gmail.com
*/

#define ArrayLength 1000

long TimeStamp[ArrayLength];
int Logic[ArrayLength];

void setup()
{
  //init Serial communication to PC
  Serial.begin(115200);

  //init value for array
  for (int i=0;i<ArrayLength; i++)
    {
        TimeStamp[i]=micros();
        Logic[i]=i;
    }
  
}

void SendToPC()
{
    for (int i=0; i<ArrayLength;i++)
    {
        Serial.println(TimeStamp[i]) ;
        TimeStamp[i]=micros();
      //  Serial.print("\t");
     //   Serial.println(Logic[i]);
        //Serial.println(i);
    }
  
}

void loop()
{
  SendToPC();
  delay(1000);
}
