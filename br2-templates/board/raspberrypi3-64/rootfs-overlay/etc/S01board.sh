#!/bin/sh

LED_STATUS_PIN=66

enable_status_pin()
{
	echo -n $LED_STATUS_PIN > /sys/class/gpio/export
	echo -n out > /sys/class/gpio/gpio$LED_STATUS_PIN/direction
	echo -n 1 > /sys/class/gpio/gpio$LED_STATUS_PIN/value
}

disable_status_pin()
{
	echo -n out > /sys/class/gpio/gpio$LED_STATUS_PIN/direction
	echo -n 0 > /sys/class/gpio/gpio$LED_STATUS_PIN/value
	echo -n $LED_STATUS_PIN > /sys/class/gpio/unexport
}

enable_blue_led_trigger()
{
	echo -n heartbeat > /sys/class/leds/blue/trigger
}

disable_blue_led_trigger()
{
	echo -n none > /sys/class/leds/blue/trigger
}

case "$1" in
start)
	disable_blue_led_trigger
	enable_status_pin
	;;
stop)
	disable_status_pin
	enable_blue_led_trigger
	;;
*)
	echo "Usage: $0 {start|stop}"
	exit 1
esac
