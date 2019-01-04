#include <FreqMeasure.h>
void setup() {
  Serial.begin(115200);
  FreqMeasure.begin();
}

double sum=0;
int count=0;

void loop() {
  if (FreqMeasure.available()) {
    // average several reading together
    sum = sum + FreqMeasure.read();
    count = count + 1;
    if (count > 1) {
      float frequency = FreqMeasure.countToFrequency(sum / count);
    //  float frequency = FreqMeasure.countToNanoseconds(sum / count);
      Serial.println(frequency*10000/10003,5);
      //Serial.println(F_CPU);
      sum = 0;
      count = 0;
    }
  }
}
