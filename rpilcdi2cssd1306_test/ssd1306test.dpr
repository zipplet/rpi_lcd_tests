{ --------------------------------------------------------------------------
  Raspberry Pi SSD1306 I2C OLED display test program
  Requires the rpiio and rpilcd libraries:
    - https://github.com/zipplet/rpiio
    - https://github.com/zipplet/rpilcd
  The directory layout should look something like this:
  dir/lcdtest/lcdtest.dpr
  dir/libs/rpiio
  dir/libs/rpilcd

  Copyright (c) Michael Nixon 2016.
  Distributed under the MIT license, please see the LICENSE file.
  -------------------------------------------------------------------------- }
program lcdtest20x4;

uses baseunix, classes, sysutils, rpii2c, rpilcdi2cssd1306;

var
  lcd: tSSD1306OLEDI2C;
  i2c: trpiI2CDevice;
  i: longint;
  i2caddress: longint;
begin
  writeln('Opening I2C device');

  { NOTE: Please set the correct i2c address or this will not work! }
  i2caddress := LCD_SSD1306_ADDR_DEFAULT;

  { If your Raspberry Pi is very old, you may need to change the device path.
    Modern Pi: I2C_DEVPATH
    Old Pi: I2C_DEVPATH_OLD }
  i2c := trpiI2CDevice.create;
  i2c.openDevice(I2C_DEVPATH, i2caddress);

  lcd := tSSD1306OLEDI2C.create(i2c);
  writeln('Initialising OLED...');

  lcd.InitialiseDisplay;

  for i := 0 to $ff do begin
    lcd.setAllPixelsOn(true);
    lcd.setContrast(i);
    sleep(2);
  end;
  for i := $ff downto $0 do begin
    lcd.setAllPixelsOn(true);
    lcd.setContrast(i);
    sleep(2);
  end;
  lcd.setAllPixelsOn(false);
  lcd.setContrast($cf);

  for i := 0 to 9 do begin
    lcd.setInverseMode(true);
    sleep(200);
    lcd.setInverseMode(false);
    sleep(200);
  end;

  sleep(1000);
  lcd.setDisplay(false);

  writeln('Closing down LCD library.');
  freeandnil(lcd);

  writeln('Closing I2C device.');
  i2c.closeDevice;
  freeandnil(i2c);
end.
