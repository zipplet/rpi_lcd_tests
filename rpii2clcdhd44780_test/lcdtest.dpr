{ --------------------------------------------------------------------------
  Raspberry Pi HD44780 I2C display test program
  Requires the rpiio and rpilcd libraries:
    - https://github.com/zipplet/rpiio
    - https://github.com/zipplet/rpilcd
  The directory layout should look something like this:
  dir/lcdtest/lcdtest.dpr
  dir/libs/rpiio
  dir/libs/rpilcd

  You will need to modify this to set the correct I2C address if this does
  not work or your display size is not 20x4, but this is a good starting
  point for experimenting with the library.

  Copyright (c) Michael Nixon 2016.
  Distributed under the MIT license, please see the LICENSE file.
  -------------------------------------------------------------------------- }
program lcdtest;

uses baseunix, classes, sysutils, rpii2c, rpii2clcdhd44780;

const
  { Define one custom character }
  customChar: array[0..7] of byte = (
    $55, $AA, $55, $AA, $55, $AA, $55, $AA
  );

  { Define an entire set of custom characters }
  customCharset: array[0..63] of byte = (
    $00, $00, $00, $00, $00, $00, $00, $FF,
    $00, $00, $00, $00, $00, $00, $FF, $FF,
    $00, $00, $00, $00, $00, $FF, $FF, $FF,
    $00, $00, $00, $00, $FF, $FF, $FF, $FF,
    $00, $00, $00, $FF, $FF, $FF, $FF, $FF,
    $00, $00, $FF, $FF, $FF, $FF, $FF, $FF,
    $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF,
    $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
  );

var
  lcd: tHD44780LCDI2C;
  i2c: cint;
  i: longint;
  i2caddress: longint;
begin
  writeln('Opening I2C device');

  { NOTE: Please set the correct i2c address or this will not work!
    If you do not know your display I2C address, please either:
     - Check the rpii2clcdhd44780.pas file (rpilcd library) and look at the
       constants, match them up to the chip on your display backpack PCB and
       the A0 / A1 / A2 pins you have shorted.
     - Install i2c-tools and probe the I2C bus with the commands below. If you
       are using a very old Raspberry Pi you may need to use bus ID 0.
       - sudo apt-get install i2c-tools
       - i2cdetect -y 1
  }
  i2caddress := HDLCD_PCF8574_ADDR_DEFAULT;

  { If your Raspberry Pi is very old, you may need to change the device path.
    Modern Pi: I2C_DEVPATH
    Old Pi: I2C_DEVPATH_OLD }
  if not i2cInit(i2c, I2C_DEVPATH, i2caddress) then begin
    writeln('Failed to initialise I2C device!');
  end;

  lcd := tHD44780LCDI2C.create(i2c);
  writeln('Initialising LCD with backlight on...');

  { NOTE: Specify the correct LCD type here. This demo requires a 20x4 LCD.
    The library currently also supports a 2LINE16COL display. More will be
    added if I manage to get hold of them. Those 2 are the 2 most common
    types. I will also be (later) adding support for directly driving the LCD
    without the I2C backpack using GPIO pins. }

  if not lcd.InitialiseDisplay(true, eHD44780_4LINE20COL) then begin
    writeln('Failed!');
    exit;
  end;

  lcd.writeStringAtLine('--------------------', 0);
  lcd.writeStringAtLine('Hello, world', 1);
  lcd.setPos(2, 2);
  lcd.writeString('* <- 2, 2');
  lcd.writeStringAtLine('Cursor on', 3);
  lcd.setCursor(true, false);
  sleep(2000);
  lcd.writeStringAtLine('Cursor blink', 3);
  lcd.setCursor(true, true);
  sleep(2000);
  lcd.writeStringAtLine('No cursor at all', 3);
  lcd.setCursor(false, false);
  sleep(2000);

  lcd.clearDisplay;
  lcd.writeStringAtLine('Backlight toggle', 0);
  sleep(2000);

  for i := 0 to 3 do begin
    lcd.setBacklight(false);
    sleep(200);
    lcd.setBacklight(true);
    sleep(200);
  end;

  lcd.writeStringAtLine('Display toggling', 0);
  sleep(2000);

  for i := 0 to 3 do begin
    lcd.setDisplay(false);
    sleep(200);
    lcd.setDisplay(true);
    sleep(200);
  end;

  lcd.clearDisplay;
  lcd.writeStringAtLine('Let''s write to the', 0);
  lcd.writeStringAtLine('display while it is', 1);
  lcd.writeStringAtLine('turned off and see', 2);
  lcd.writeStringAtLine('what happens. Ready?', 3);
  sleep(5000);
  lcd.clearDisplay;
  lcd.writeStringAtLine('Turning the display', 0);
  lcd.writeStringAtLine('off, writing, then', 1);
  lcd.writeStringAtLine('turning it back on.', 2);
  sleep(5000);
  
  lcd.setDisplay(false);
  lcd.clearDisplay;
  for i := 0 to 3 do begin
    lcd.writeStringAtLine('01234567890123456789', i);
  end;
  lcd.setDisplay(true);
  sleep(3000);
  lcd.clearDisplay;
  lcd.writeStringAtLine('It worked! The', 0);
  lcd.writeStringAtLine('text appeared and', 1);
  lcd.writeStringAtLine('you could not see', 2);
  lcd.writeStringAtLine('the slow writing.', 3);
  sleep(5000);


  lcd.clearDisplay;
  lcd.writeStringAtLine('Custom char test', 0);
  lcd.setAllCustomChars(customCharset);
  lcd.writeStringAtLine(#0 + #1 + #2 + #3 + #4 + #5 + #6 + #7, 1);
  sleep(3000);
  lcd.writeStringAtLine('Slowly replacing...', 2);
  for i := 0 to 7 do begin
    lcd.setCustomChar(i, customChar);
    sleep(500);
  end;
  sleep(2000);
  lcd.clearDisplay;
  lcd.setBacklight(false);

  writeln('Closing down LCD library.');
  freeandnil(lcd);

  writeln('Closing I2C device.');
  if not i2cClose(i2c) then begin
    writeln('Failed to close I2C device!');
  end;
end.