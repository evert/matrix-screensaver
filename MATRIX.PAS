program Matrix;

uses crt, up4;

var kleur,x,y, t: integer;
    c:char;
    step:byte;

procedure coolwrite(s:string);
var i:integer;
begin
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
  write('Û');
end;

begin
  screenmode(40,25,16);
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
  for x:=1 to 80 do for y:=1 to 50 do begin
    kleur:=random(2);
    if kleur=0 then textcolor(2);
    if kleur=1 then textcolor(10);
    gotoxy(x,y);
    if (x<79) or (y<50) then write(' ');
  end;
  repeat
    x:=random(80)+1;
    y:=random(50)+1;
    if (x mod 10 <> 0) then begin
      if ((step<>1) and (step<4)) or ((x<25) or (x>55) or (y<23) or (y>27)) then
        if step>=4 then putchar(x,y,' ') else
        if ((x<>79) or (y<>49)) then begin
          kleur:=random(2);
          if kleur=0 then textcolor(2);
          if kleur=1 then textcolor(10);
          gotoxy(x,y);
          write(chr(random(9)+48));
        end else putchar(x,y,chr(random(9)+48));
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
  cls;
end.