# rpii2clcdhd44780 - I2C HD44780 LCD test program

Demonstrates the usage of the rpii2clcdhd44780 driver included with the rpilcd library. Out of the box, it requires a 20x4 LCD.

## Notes

* You need to alter the code to match the I2C address of your "backpack" module. Instructions in the source code.
* If you use a very old Raspberry Pi, the I2C device address may also be different. More instructions in the source code.

## Library dependencies

All of these are available on my Github account.

* rpiio
* rpilcd

## Directory layout example

**Please always use this standardised directory layout when using any of my freepascal or Delphi programs. The compilation scripts assume that the libraries will always be found by looking one directory back, and under libs/<name>**

* /home/youruser/projects/my_awesome_program
* /home/youruser/projects/libs/rpiio
* /home/youruser/projects/libs/rpilcd

