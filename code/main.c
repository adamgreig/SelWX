/*
 * A skeleton main.c
 * Add your own code!
 */

// Load CMSIS and peripheral library and configuration
#include "stm32f10x.h"

// Peripheral configuration functions
void GPIO_Config();

// A simple busy wait loop
void Delay(volatile unsigned long delay);

int main(void) {
    // Setup STM32 system (clock, PLL and Flash configuration)
    SystemInit();
	
	// Setup the GPIOs
	GPIO_Config();
	
    for(;;) {
		// Turn on PB0, turn off PB1
		GPIO_SetBits(GPIOA, GPIO_Pin_8);
		Delay(0xAFFFF);
		
		// Turn off PB0, turn on PB1
		GPIO_ResetBits(GPIOA, GPIO_Pin_8);
		Delay(0xAFFFF);
    }
}


void Delay(volatile unsigned long delay) {
	for(; delay; --delay );
}

void GPIO_Config() {
	GPIO_InitTypeDef	GPIO_InitStructure;
	
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_8;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_10MHz;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_Init(GPIOA, &GPIO_InitStructure);
}
