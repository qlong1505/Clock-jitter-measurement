//timer1 will interrupt when run full scale 16 bit (use TOV1 interrupt)
//Prescale = 1;
// interrupt frequency = 16000000/65536
const byte interruptPin = 2;
void setup()
{
	Serial.begin(9600);

	//---set up timer 1------------------------------------------
	cli();//Stop interrrupt;

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
	pinMode(interruptPin, INPUT_PULLUP);
	attachInterrupt(digitalPinToInterrupt(interruptPin), CLK_DECT, RISING);
}
unsigned long counter = 0;

ISR(TIMER1_OVF_vect)
{
	counter += 1;
}
unsigned long tcnt1; //variable to read timer 1 value
char oldSREG; //store old config register
float period = 0;	//amended to hold more than 65536 (could be nearly double this)
void CLK_DECT()
{
	//need to disable interrupt while reading timer01 value, store config register in a oldSRED
	oldSREG = SREG;
	
	//disable interrupt
	cli();

	//read current value of timer01 - 16bit
	tcnt1 = TCNT1;

	//push back config register
	SREG = oldSREG;

	//calculate clock input period.
	period = (counter * 65536 + tcnt1 - period) / 16e6;
	
	Serial.print(tcnt1);  Serial.print(",");
	Serial.print(counter);  Serial.print(",");
	Serial.println(period);

	//reset counter of timer interrupt.
	counter = 0;
}
void loop() 
{
	// put your main code here, to run repeatedly:
	//  Serial.println(counter);
	//  delay(500);
}