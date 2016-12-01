{ --------------------------------------------------------------------------
  Raspberry Pi HD44780 I2C display test program
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
program hdlcdtest;

uses baseunix, classes, sysutils, rpii2c, rpilcdhd44780;

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
  lcd: trpilcdHD44780I2C;
  i2c: trpiI2CDevice;
  init: rHD44780InitParams;
  i: longint;
  i2caddress: longint;
  s: ansistring;
  w, h: longint;
begin
  if paramCount < 3 then begin
    writeln('rpilcdhd44780 driver test program, (c) Michael Nixon 2006.');
    writeln('Usage: hdlcdtest <mode> <interface> <displaytype> [i2caddress]');
    writeln;
    writeln('mode: Specify one of:');
    writeln('  direct - talk to the display directly (what you probably want)');
    writeln('  daemon - use the rpilcd daemon');
    writeln;
    writeln('interface: Specify one of:');
    writeln('  i2c - use an I2C module (PCF8574 or PCF8574A based expander)');
    writeln('  4bit - directly driven display with GPIO pins (unsupported right now)');
    writeln('  8bit - directly driven display with GPIO pins (unsupported right now)');
    writeln;
    writeln('displaytype: Specify one of:');
    writeln('  20x4, 16x2, 40x2 - the display size');
    writeln;
    writeln('NOTE: If <mode> is ''i2c'' you may override the I2C address.');
    writeln('      Prefix the address with $ to use hexadecimal.');
    writeln('      (Due to your shell, you will probably need to write \$)');
    writeln;
    writeln('Examples:');
    writeln('hdlcdtest direct i2c 20x4');
    writeln('hdlcdtest direct i2c 16x2 $2A');
    writeln('hdlcdtest direct 8bit 40x2');
    exit;
  end;

  i2c := nil;
  init.backlightOn := true;
  init.displayOn := true;

  s := lowercase(paramStr(1));
  if s = 'direct' then begin
    { TODO }
  end else begin
    writeln('mode: Unknown or unsupported mode');
    exit;
  end;
  
  s := lowercase(paramStr(2));
  if s = 'i2c' then begin
    if paramCount < 4 then begin
      i2cAddress := HD44780_PCF8574_ADDR_DEFAULT;
      writeln('Using the default I2C address');
    end else begin
      i2cAddress := strtoint(paramStr(4));
    end;
    writeln('Opening I2C device at address $' + inttohex(i2cAddress, 2));
    i2c := trpiI2CDevice.create;
    i2c.openDevice(i2caddress);
    init.i2cDevice := i2c;
    lcd := trpilcdHD44780I2C.create;
  end else begin
    writeln('interface: Unknown or unsupported interface');
    exit;
  end;

  s := lowercase(paramStr(3));
  if s = '20x4' then begin
    init.lcdType := eHD44780_4LINE20COL;
    w := 20;
    h := 4;
  end else if s = '16x2' then begin
    init.lcdType := eHD44780_2LINE16COL;
    w := 16;
    h := 2;
  end else if s = '40x2' then begin
    init.lcdType := eHD44780_2LINE40COL;
    w := 40;
    h := 2;
  end else begin
    writeln('displaytype: Unknown or unsupported type');
    exit;
  end;

  writeln('Initialising LCD with backlight on...');
  lcd.InitialiseDisplay(init);

  lcd.writeStringAtLine('Hello, world', 0);
  lcd.setPos(1, 1);
  lcd.writeString('* <- 1, 1');
  sleep(2000);

  lcd.clearDisplay;
  lcd.writeStringAtLine('Cursor on', 0);
  lcd.setCursor(true, false);
  sleep(2000);
  lcd.writeStringAtLine('Cursor blink', 0);
  lcd.setCursor(true, true);
  sleep(2000);
  lcd.writeStringAtLine('No cursor...', 0);
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

  lcd.writeStringAtLine('Display toggle  ', 0);
  sleep(2000);

  for i := 0 to 3 do begin
    lcd.setDisplay(false);
    sleep(200);
    lcd.setDisplay(true);
    sleep(200);
  end;

  lcd.clearDisplay;
  lcd.writeStringAtLine('Write while off', 0);
  sleep(5000);
  
  lcd.setDisplay(false);
  lcd.clearDisplay;
  setlength(s, w);
  fillbyte(s[1], w, ord('#'));
  for i := 0 to h - 1 do begin
    lcd.writeStringAtLine(s, i);
  end;
  lcd.setDisplay(true);
  sleep(3000);
  lcd.clearDisplay;
  lcd.writeStringAtLine('It worked!', 0);
  sleep(3000);


  lcd.clearDisplay;
  lcd.writeStringAtLine('Custom chars', 0);
  lcd.setAllCustomChars(customCharset);
  lcd.writeStringAtLine(#0 + #1 + #2 + #3 + #4 + #5 + #6 + #7, 1);
  sleep(3000);
  lcd.writeStringAtLine('Replacing...', 0);
  for i := 0 to 7 do begin
    lcd.setCustomChar(i, customChar);
    sleep(500);
  end;
  sleep(2000);
  lcd.clearDisplay;
  lcd.setBacklight(false);

  writeln('Closing down LCD library.');
  freeandnil(lcd);
  
  { If we were using I2C mode }
  if assigned(i2c) then begin
    writeln('Closing I2C device.');
    i2c.closeDevice;
    freeandnil(i2c);
  end;
end.
