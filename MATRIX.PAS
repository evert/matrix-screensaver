program matrix;

uses crt,up4;

procedure coolwrite(s:string);
var i:integer;
    blockplace: integer;
begin
  textcolor(10);
  for i:=1 to length(s) do begin
    sound(50);
    delay(1);
    nosound;
    gotoxy(i,wherey);
    write(s[i]+'Û');
    realdelay(1);
  end;
  gotoxy(length(s)+1,wherey);
  write(' ');
  writeln;
  blockplace:=wherex;
  write('Û');
end;

type moduletype = record
  interfaceversion: string[5];
  name: string[20];
  version: string[5];
  longname: string[80];
  infoln: byte;
  info: array[1..10] of string;
  commands: byte;
  command: array[1..10] of string[4];
  commandhelpln: array[1..10] of byte;
  commandhelp: array[1..10,1..10] of string[80];
end;

type xy=record
  x: byte;
  y: byte;
end;

var step,kleur     : byte;
    oldtext        : boolean;
    c              : char;
    screen         : array [0..7999] of byte absolute $B800:0;
    sscreen        : array [0..7999] of byte;
    sxy,cd         : xy;
    i              : integer;
    f              : file;
    module         : moduletype;
    command        : string[4];



 begin
  if paramstr(1) = 'INFO' then begin
    module.interfaceversion:='3.2';
    module.name:='Matrix';
    module.version:='1.1';
    module.longname:='The MaTRiX Screensaver';
    module.infoln:=5;
    module.info[1]:='The MaTRiX Screensaver (c)2001 by YVII';
    module.info[2]:='';
    module.info[3]:='Created for Port Sniffer 3.2';
    module.info[4]:='';
    module.info[5]:='For more info goto: http://evert.isnw.org';
    module.commands:=1;
    module.command[1]:='MTRX';
    module.commandhelpln[1]:=2;
    module.commandhelp[1,1]:='MTRX Starts the MaTRiX screensaver';
    module.commandhelp[1,2]:='MTRX   Starts the MaTRiX screensaver';
    assign(f,'MODULE.DAT');
    rewrite(f,1);
    blockwrite(f,module,sizeof(module));
    close(f);
  end;
  if paramstr(1)='MTRX' then begin
  for i:=0 to 7999 do sscreen[i]:=screen[i];
  sxy.x:=wherex;
  sxy.y:=wherey;
  clrscr;
  textcolor(10);
  Coolwrite('Wake up Neo....');
  realdelay(100);
  clrscr;
  Coolwrite('Follow the white rabbit');
  realdelay(100);
  clrscr;
  Coolwrite('Knock Knock');
  realdelay(100);
  screenmode(80,50,16);
  clrscr;
  hidecursor;
  step:=0;
  for cd.x:=1 to 80 do for cd.y:=1 to 50 do begin
    kleur:=random(2);
    if kleur=0 then textcolor(2);
    if kleur=1 then textcolor(10);
    gotoxy(cd.x,cd.y);
    if (cd.x<79) or (cd.y<50) then write(' ');
  end;
  repeat
    cd.x:=random(80)+1;
    cd.y:=random(50)+1;
    if (cd.x mod 10 <> 0) then begin
      if ((step<>1) and (step<4)) or ((cd.x<25) or (cd.x>55) or (cd.y<23) or (cd.y>27)) then
        if step>=4 then putchar(cd.x,cd.y,' ') else
        if ((cd.x<>79) or (cd.y<>49)) then begin
          kleur:=random(2);
          if kleur=0 then textcolor(2);
          if kleur=1 then textcolor(10);
          gotoxy(cd.x,cd.y);
          write(chr(random(9)+48));
        end else putchar(cd.x,cd.y,chr(random(9)+48));
    end;
    if keypressed then begin
      c:=readkey;
      step:=step+1;
      if step=1 then begin
        kader(25,23,55,27,0,10,singleline);
        writeln;
        writeln('    The Matrix has you!');
        window(1,1,80,50);
      end;
      if step=2 then begin
        kader(25,23,55,27,0,10,'      ');
        window(1,1,80,50);
      end;
      if step=4 then begin
        kader(25,23,55,27,0,10,singleline);
        textcolor(4+8);
        writeln;
        writeln('      System failure!');
        window(1,1,80,50);
      end;
      if step=5 then begin
        kader(25,23,55,27,0,10,singleline);
        textcolor(4+8);
        writeln('    Made by YVII (c)2001');
        writeln('    http://evert.isnw.org');
        write('   evert@dutchdevelopers.nl');
        window(1,1,80,50);
      end;
    end;
    if (step=3) or (step=4) then delay(1);
  until step=6;
  for i:=0 to 7999 do screen[i]:=sscreen[i];
  gotoxy(sxy.x,sxy.y);
  end;
end.
