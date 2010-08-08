/*
 * SelWX
 * Autonomous weather station
 */

#include <libopenstm32/rcc.h>
#include <libopenstm32/gpio.h>

void gpio_setup(void)
{
    // Enable GPIOC peripheral clock
    rcc_peripheral_enable_clock(&RCC_APB2ENR, RCC_APB2ENR_IOPCEN);

    // Set GPIO6 and 7 to outputs (LEDs)
    gpio_set_mode(
        GPIOC,
        GPIO_MODE_OUTPUT_2_MHZ,
        GPIO_CNF_OUTPUT_PUSHPULL,
        GPIO6 | GPIO7
    );

    // Set GPIO11 and 12 to inputs
    gpio_set_mode(
        GPIOC,
        GPIO_MODE_INPUT,
        GPIO_CNF_INPUT_PULL_UPDOWN,
        GPIO11 | GPIO12
    );

    // Set pullup resistors on GPIO11 and 12
    gpio_set(GPIOC, GPIO11 | GPIO12);
}

int main(void)
{
    gpio_setup();

    while (1) {
        // Read the wind speed and rain sensors, then write their
        // status to the LEDs.
        int weather = gpio_get(GPIOC, GPIO11 | GPIO12);

        if(weather & GPIO11)
            gpio_clear(GPIOC, GPIO6);
        else
            gpio_set(GPIOC, GPIO6);

        if(weather & GPIO12)
            gpio_clear(GPIOC, GPIO7);
        else
            gpio_set(GPIOC, GPIO7);
    }

    return 0;
}
