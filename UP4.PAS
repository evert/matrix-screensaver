{$O+}
unit UP4;

interface

uses crt, dos;

type
Menutype = record
  items              : byte;
  item               : array[0..40] of string[80];
  enabled            : array[0..40] of boolean;
  textkleur          : byte;
  achtergrondkleur   : byte;
  selectiekleur      : byte;
  selectieachtergrond: byte;
  disabledkleur      : byte;
  uitkomst           : byte;
end;
LineType = string[6];
Fontinfotype = record
  Bestand  : string;
  Naam     : string;
  Breedte  : byte;
  Hoogte   : byte;
  Auteur   : string;
  Info     : string;
  BCversie : string;
end;


var filefound     : boolean;
    cursor        : boolean;
    keylocks      : BYTE ABSOLUTE $0040:$0017;
    bootlock      : boolean;
    ignore_errors : boolean;
    NRTMethode    : byte;
    UPfout        : byte;
    Fontinfo      : FontinfoType;

const K=1024;
      M=1024*1024;
      G=1024*1024*1024;
      SCRLOCK  = 16;
      NUMLOCK  = 32;
      CAPLOCK  = 64;
      singleline : linetype = 'ÚÄ¿³ÀÙ';
      doubleline : linetype = 'ÉÍ»ºÈŒ';
      boldline   : linetype = 'ÛßÛÛßß';
      UltraPascal__Gemaakt_Door_Evert_Pot__1998_2001:String =
        'UltraPascal 4.0  Gemaakt Door Evert Pot (c)1998-2001  WeirdEvert@HotMail.Com';

procedure ABSORBKEY;
procedure BIGCHAR(x,y:integer;s:string;fontfile:string);
procedure CENTER(s:string);
procedure CHECKFILE(s:string);
procedure COLDBOOT;
procedure CLS;
procedure DECRYPT(bestand1,bestand2:string);
procedure ENCRYPT(bestand1,bestand2:string);
procedure FOUT(f:byte);
procedure GETCHAR(x,y:byte; var c:char);
procedure HIDECURSOR;
procedure INFO;
procedure KADER(x1,y1,x2,y2,c1,c2:integer;linestyle:linetype);
procedure OPENSCREEN(s:string);
procedure PLAY(nt:char;ms:longint);
procedure PUTCHAR(x,y:byte; c:char);
procedure REALDELAY(h:longint);
procedure RUNMENU(var menu:menutype);
procedure SAVESCREEN(s:string);
procedure SCREENMODE (a,b,c:word);
procedure SETCAPLOCK(b:boolean);
procedure SETNUMLOCK(b:boolean);
procedure SETSCRLOCK(b:boolean);
procedure SHOWCURSOR;
procedure UPDATELOCKS;
procedure WAIT;
procedure WAITFORKEY(var key: byte);
procedure WARMBOOT;
procedure ZOEKINBESTAND(var f:text;s:string);

function INT2STR(i:integer):string;
function GETCAPLOCK :boolean;
function GETNUMLOCK :boolean;
function GETSCRLOCK :boolean;
function SIS(s2:string;s1:string):boolean;
function STR2INT(s:string):integer;
function UPPERCASE(s:string):string;

implementation

function Int2Str;
var s:string;
begin
  str(i,s);
  int2str:=s;
end;

function Str2Int;
var i:integer;
begin
  val(s,i,i);
  str2int:=i;
end;

procedure fout;
begin
  UPfout:=f;
  if not ignore_errors then begin
    cls;
    if f=1  then writeln('ULTRAPAS Fout 1:  corrupte parameter');
    if f=2  then writeln('ULTRAPAS Fout 2:  corrupte combinatie van parameters');
    if f=3  then writeln('ULTRAPAS Fout 3:  characters mogen geen hoger nummer dan 127 hebben');
    if f=4  then writeln('ULTRAPAS Fout 4:  schermresolutie komt niet overeen met resolutie in bestand');
    if f=5  then writeln('ULTRAPAS Fout 5:  monochrome schermmodus word niet door deze opdracht ondersteunt');
    if f=6  then writeln('ULTRAPAS Fout 6:  Onjuiste bestandsnaam');
    if f=7  then writeln('ULTRAPAS Fout 7:  Kan bestand niet vinden');
    if f=8  then writeln('ULTRAPAS Fout 8:  Onjuiste noot (CDEFGAB)');
    if f=9  then writeln('ULTRAPAS Fout 9:  Kan VGA256MODUS niet uitvoeren!');
    if f=10 then writeln('ULTRAPAS Fout 10: Fout in MenuType');
    if f=11 then writeln('ULTRAPAS Fout 11: Fout in bestand');
    if f=12 then writeln('ULTRAPAS Fout 12: Kan opgegeven string niet in bestand vinden');
    if f=13 then writeln('ULTRAPAS Fout 13: Onjuiste NRT methode (1 of 2 worden alleen herkend)');
    if f=14 then writeln('ULTRAPAS Fout 14: Verkeerde BIGCHAR versie');
    if f=15 then writeln('ULTRAPAS Fout 15: Bootlock is op TRUE ingesteld');
    if f=16 then writeln('ULTRAPAS Fout 16: BGI graphics niet geinstalleerd');
    if f=17 then writeln('ULTRAPAS Fout 17: Kan benodigde grafische hardware niet vinden');
    if f=18 then writeln('ULTRAPAS Fout 18: Fout in bestand');
    if f=19 then writeln('ULTRAPAS Fout 19: Niet genoeg geheugen');
    if f=20 then writeln('ULTRAPAS Fout 20: Verkeerde grafische modus');
    halt(f);
  end;
end;

PROCEDURE UPDATELOCKS; ASSEMBLER;
asm
  mov ah, 11
  int $21
End;

procedure Showcursor;
var regs:registers;
    el,e2,cf:byte;

begin
intr($11,regs);
cf:=regs.ax;cf:=(cf shr 4) and 3;regs.ax:=$0100;
if (cf<>3) then begin
  el:=6;
  e2:=7;
end else begin
  el:=12;
  e2:=13;
end;
regs.cx:=((el shl 8)+e2);intr($10,regs);
cursor:=true;
end;

procedure Hidecursor;
var regs:registers;
begin
regs.ax:=$0100;
regs.cx:=31 shl 8;
intr($10,regs);
cursor:=false;
end;

function sis;
var i,j,k:integer;
    a:boolean;
    b:boolean;
begin
  sis:=false;
  i:=1;
  j:=1;
  k:=0;
  b:=false;
  while (i<length(s1)+1) do begin
    a:=false;
    if s1[i]=s2[j] then begin
      j:=j+1;
      a:=true;
    end;
    if a=true then
      k:=k+1;
    if a=false then begin
      j:=1;
      k:=0;
    end;
    if k=length(s2) then
      sis:=true;
    i:=i+1;
  end;
end;

function uppercase(s:string):string;
var i:integer;
begin
  for i:=1 to length(s) do s[i]:=upcase(s[i]);
  uppercase:=s;
end;

procedure CLS;
begin
  textmode(co80);textbackground(0);textcolor(7);window(1,1,80,25);clrscr;
end;

procedure WAIT;
var c:char;
begin
  repeat
    if keypressed then c:=readkey;
  until not keypressed;
  c:=readkey;
end;

procedure SCREENMODE;
begin
  if (a<>40) and (a<>80) then fout(1);
  if (b<>25) and (b<>50) then fout(1);
  if (c<>2) and (c<>16) then fout(1);
  if (a=40) and (b=25) and (c=2)  then fout(2);
  if (a=40) and (b=25) and (c=16) then textmode(1);
  if (a=40) and (b=50) and (c=2)  then fout(2);
  if (a=40) and (b=50) and (c=16) then textmode(257);
  if (a=80) and (b=25) and (c=2)  then textmode(7);
  if (a=80) and (b=25) and (c=16) then textmode(3);
  if (a=80) and (b=50) and (c=2)  then textmode(263);
  if (a=80) and (b=50) and (c=16) then textmode(259);
end;

procedure INFO;
begin
  center('ULTRAPAS 4.0 (c)1998-2001 by Evert Pot      Info: WeirdEvert@Hotmail.com');
end;

procedure SAVESCREEN;
var f:text;
    x,y,i,k:integer;
    ok, punt:boolean;
    c   : char;

begin
  ok:=true;
  punt:=false;
  s:=uppercase(s);
  if length(s)<1 then fout(6);
  for i:=1 to length(s) do begin
    if (s[i]='.') and (i>9) then ok:=false;
    if s[i]='.' then punt:=true;
  end;
  if (punt=false) and (i>8) then ok:=false;
  if i>12 then ok:=false;
  if ok=false then fout(6);
  if punt=false then s:=s+'.NRT';
  if (lastmode=0) or (lastmode=1) then begin x:=40; y:=25; k:=16; end;
  if lastmode=256 then begin x:=40; y:=50; k:=16 end;
  if lastmode=257 then begin x:=40; y:=50; k:=16 end;
  if lastmode=7 then begin x:=80; y:=25; k:=2; end;
  if (lastmode=2) or (lastmode=3) then begin x:=80; y:=25; k:=16 end;
  if lastmode=263 then begin x:=80; y:=50; k:=2; end;
  if lastmode=258 then begin x:=80; y:=50; k:=16 end;
  if lastmode=259 then begin x:=80; y:=50; k:=16 end;
  if k=2 then fout(5);
  assign(f,s);
  rewrite(f);
  if (NRTmethode<>1) and (NRTmethode<>2) then Fout(13);
  if NRTmethode=2 then begin
    writeln(f,'!Dit bestand is gemaakt m.b.v. Ultrapas 4.0     Made by Ruby Studio''s');
    writeln(f,x);
    writeln(f,y);
    for i:=0 to x*y*2 do begin
      c:=chr(mem[$B800:i]);
      if ord(c)<=32 then
        write(f,chr(32) + chr(ord(c)+33))
      else
        write(f,c);
      if (i mod 80=0) then writeln(f,'');
    end;
  end;
  if NRTmethode=1 then begin
    writeln(f,'"Dit bestand is gemaakt m.b.v. Ultrapas 4.0     Made by Ruby Studio''s');
    writeln(f,x);
    writeln(f,y);
    for i:=0 to x*y*2 do begin
      write(f,mem[$B800:i]:3);
      if (i mod 25=0) then writeln(f,'');
    end;
  end;
  close(f);
end;

procedure OPENSCREEN;
var f:text;
    x,y,i,j,k:integer;
    st:string[3];
    methode:byte;
    c : char;


begin
  if lastmode=0 then begin x:=40; y:=25; k:=16; end;
  if lastmode=1 then begin x:=40; y:=25; k:=16; end;
  if lastmode=2 then begin x:=80; y:=25; k:=16 end;
  if lastmode=3 then begin x:=80; y:=25; k:=16 end;
  if lastmode=7 then begin x:=80; y:=25; k:=2; end;
  if lastmode=256 then begin x:=40; y:=50; k:=16 end;
  if lastmode=257 then begin x:=40; y:=50; k:=16 end;
  if lastmode=258 then begin x:=80; y:=50; k:=16 end;
  if lastmode=259 then begin x:=80; y:=50; k:=16 end;
  if lastmode=263 then begin x:=80; y:=50; k:=2; end;
  if k=2 then fout(5);
  checkfile(s);
  if not filefound then fout(7);
  assign(f,s);
  reset(f);
  readln(f,st);
  methode:=1;
  if (st[1]='"') then methode:=1;
  if (st[1]='!') then methode:=2;
  readln(f,st);
  val(st,i,i);
  if i<>x then fout(4);
  readln(f,st);
  val(st,i,i);
  if i<>y then fout(4);
  if methode=1 then begin
    for i:=0 to x*y*2 do begin
      read(f,st);
      val(st,j,j);
      MEM[$B800:i]:=j;
      if i mod 25=0 then readln(f,st);
    end;
  end;
  if methode=2 then begin
    for i:=0 to x*y*2 do begin
      read(f,c);
      if c=chr(32) then begin
        read(f,c);
        c:=chr(ord(c)-33);
      end;
      MEM[$B800:i]:=ord(c);
      if i mod 80=0 then readln(f,st);
    end;
  end;
  close(f);
end;


procedure BIGCHAR;
var
    chars        : array[0..15,0..15] of char;
    charsh       : byte;
    charsbr      : byte;
    naam, auteur : string[25];
    infostring    : string[60];
    versionstring : string[5];

const seg=$F000;
      off=$FA6E;

var oo:array[1..8] of boolean;
    i,j,k:integer;
    bin:integer;
    f: file;

begin
  if fontfile='' then begin
    gotoxy(x,y);
    for j:=1 to length(s) do begin
      if ord(s[j])>127 then s[j]:=' ';
      for i:=0 to 7 do begin
        bin:=0;
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 127 then begin write('Û'); bin:=bin+128; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 63 then begin write('Û'); bin:=bin+64; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 31 then begin write('Û'); bin:=bin+32; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 15 then begin write('Û'); bin:=bin+16; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 7 then begin write('Û'); bin:=bin+8; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 3 then begin write('Û'); bin:=bin+4; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 1 then begin write('Û'); bin:=bin+2; end else write(' ');
        if mem[seg:off+(ord(s[j])*8)+i]-bin > 0 then begin write('Û'); bin:=bin+1; end else write(' ');
        writeln;
        gotoxy(x+9*(j-1),wherey);
      end;
      writeln;
      gotoxy(x+9*(j),y);
    end;
    fontinfo.bestand:='';
    fontinfo.bcversie:='1.0';
    fontinfo.auteur:='Evert Pot';
    fontinfo.hoogte:=8;
    fontinfo.breedte:=8;
    fontinfo.naam:='Standaard ASCII';
    fontinfo.info:='BigChar 1.0 by Evert Pot (c)2001 weirdevert@hotmail.com';
  end else begin
    checkfile(fontfile);
    if not filefound then fout(7);
    assign(f,fontfile);
    for i:=1 to length(s) do begin
      s[i]:=upcase(s[i]);
      reset(f,1);
      blockread(f, versionstring, sizeof(versionstring));
      blockread(f, infostring, sizeof(infostring));
      blockread(f, naam, sizeof(naam));
      blockread(f, auteur, sizeof(auteur));
      blockread(f, charsh, sizeof(charsh));
      blockread(f, charsbr, sizeof(charsbr));
      if versionstring<>'2.0' then fout(14);
      j:=31;
      repeat
        j:=j+1;
        blockread(f, chars, sizeof(chars));
      until j=ord(s[i]);
      for j:=0 to charsbr-1 do
         for k:=0 to charsh-1 do begin
          gotoxy(x+j+((i-1)*(charsbr)),y+k);
          write(chars[k,j]);
        end;
      close(f);
    end;
    fontinfo.bestand:=fontfile;
    fontinfo.bcversie:=versionstring;
    fontinfo.auteur:=auteur;
    fontinfo.hoogte:=charsh;
    fontinfo.breedte:=charsbr;
    fontinfo.naam:=naam;
    fontinfo.info:=infostring;
  end;
end;

procedure CENTER;
begin
  gotoxy(40-length(s) div 2,wherey);
  writeln(s);
end;

procedure KADER;
var i:integer;
begin
  Textbackground(c1);
  Textcolor(c2);
  window(x1,y1,x2,y2+1);
  gotoxy(1,1);
  write(linestyle[1]);
  for i:=1 to x2-x1-1 do write(linestyle[2]);
  write(linestyle[3]);
  for i:=1 to y2-y1-1 do begin
    write(linestyle[4]);
    gotoxy(x2-x1+1,wherey);
    write(linestyle[4]);
  end;
  write(linestyle[5]);
  for i:=1 to x2-x1-1 do write(linestyle[2]);
  write(linestyle[6]);
  window(x1+1,y1+1,x2-1,y2-1);clrscr;
end;

procedure RUNMENU;
var x,y:integer;
    c:char;
    i:integer;

begin
x:=wherex;
y:=wherey;
if menu.items=0 then fout(10);
with menu do begin
  textcolor(selectiekleur);
  textbackground(selectieachtergrond);
  writeln(item[0]);
  textcolor(textkleur);
  textbackground(achtergrondkleur);
  for i:=1 to items-1 do begin
    if enabled[i]=true then textcolor(textkleur);
    if enabled[i]=false then textcolor(disabledkleur);
    writeln(item[i]);
  end;
  uitkomst:=0;
  repeat
  c:=readkey;
  if ord(c)=0 then begin
    c:=readkey;
    if ord(c)=80 then if uitkomst=items-1 then uitkomst:=0 else uitkomst:=uitkomst+1;
    if ord(c)=72 then if uitkomst=0 then uitkomst:=items-1 else uitkomst:=uitkomst-1;
    if ord(c)=81 then uitkomst:=items-1;
    if ord(c)=73 then uitkomst:=0;
  end;
  gotoxy(x,y);
  textcolor(textkleur);
  textbackground(achtergrondkleur);
  for i:=0 to items-1 do begin
    if enabled[i]=true then textcolor(textkleur);
    if enabled[i]=false then textcolor(disabledkleur);
    writeln(item[i]);
  end;
  textcolor(selectiekleur);
  textbackground(selectieachtergrond);
  gotoxy(1,y+uitkomst);
  writeln(item[uitkomst]);
  if (ord(c)=13) and (enabled[uitkomst]=false) then write(chr(7));
  until (ord(c)=13) and (enabled[uitkomst]=true);
 end;
end;

procedure play(nt:char;ms:longint);
var b,e:boolean;
    w:word;

begin
b:=false;
e:=true;
if nt='A' then begin w:=880;b:=true;end;
if nt='B' then begin w:=988;b:=true;end;
if nt='C' then begin w:=523;b:=true;end;
if nt='D' then begin w:=587;b:=true;end;
if nt='E' then begin w:=659;b:=true;end;
if nt='F' then begin w:=699;b:=true;end;
if nt='G' then begin w:=784;b:=true;end;

if b=false then begin fout(8); e:=false;end;

if e=true then begin
  sound(w);
  realdelay(ms);
  nosound;
  end;
end;

procedure ABSORBKEY;
var c:char;
begin
repeat
  if keypressed then c:=readkey;
until keypressed=false;
end;

procedure CHECKFILE;
var
  DirInfo: SearchRec;

begin
  filefound:=true;
  FindFirst(s, Anyfile, DirInfo);
  if doserror<>0 then filefound:=false;
end;

procedure ENCRYPT;
var f1,f2:text;
    c:char;
    b:byte;

begin
checkfile(bestand1);
if filefound=false then fout(7);
assign(f1,bestand1);
assign(f2,bestand2);
reset(f1);
rewrite(f2);
repeat
  read(f1,c);
  b:=ord(c);
  if (b>31) and (b<250) then begin
    b:=b+5;
  end else if (b>=250) then begin
    b:=31+(250-b);
  end;
  write(f2,chr(b));
until eof(f1);
close(f1);
close(f2);
end;

procedure DECRYPT;
var f1,f2:text;
    c:char;
    b:byte;

begin
checkfile(bestand1);
if filefound=false then fout(7);
assign(f1,bestand1);
assign(f2,bestand2);
reset(f1);
rewrite(f2);
repeat
  read(f1,c);
  b:=ord(c);
  if (b>36) then begin
    b:=b-5;
  end else if (b>=36) and (b>31) then begin
    b:=250-(b-31);
  end;
  write(f2,chr(b));
until eof(f1);
close(f1);
close(f2);
end;

{$F+}
function TestDetect : Integer;
{ Autodetect function. Assume hardware is
  always present. Return value = recommended
  default mode. }
begin
  TestDetect := 1;
end;
{$F-}

procedure REALDELAY;
var
  u, m, s, hund : Word;
  u2,m2,s2,hund2: longint;
  u3,m3,s3,hund3: longint;

begin
GetTime(u,m,s,hund);
u2:=u;
u3:=u;
m2:=m;
s2:=s;
hund2:=hund+h;
hund3:=hund2 mod 100;
s2:=s2 + (hund2 div 100);
s3:=s2 mod 60;
m2:=m2 + (s2 div 60);
m3:=m2 mod 60;
u2:=u2 + (m2 div 60);
u3:=u2 mod 24;
repeat
  GetTime(u,m,s,hund);
until (u>u3) or ((m>m3) and (u=u3)) or ((s>s3) and (m=m3) and (u=u3)) or
  ((hund>hund3) and (s=s3) and (m=m3) and (u=u3));
end;

procedure ZOEKINBESTAND;
var s2:string;
begin
  {$I+}
  repeat
    readln(f,s2);
    if IOResult<>0 then fout(11);
  until (s2=s) or (eof(f));
  if eof(f) then fout(12);
  {$I-}
end;


procedure WAITFORKEY;

var Code, Code2: Byte;

begin
  Code := Port[ $60 ];
  repeat
    Code2 := Port[ $60 ];
  until (code2<94);
  key:=code2;
  absorbkey;
end;

procedure SetScrlock;
begin
  if b=true then begin
    If KeyLocks=0                 then KeyLocks := ScrLock;
    If KeyLocks=NumLock           then KeyLocks := ScrLock + NumLock;
    If KeyLocks=CapLock           then KeyLocks := ScrLock + CapLock;
    If KeyLocks=CapLock + NumLock then KeyLocks := ScrLock + CapLock + NumLock;
  end;
  if b=false then begin
    If KeyLocks=ScrLock                     then KeyLocks := 0;
    If KeyLocks=ScrLock + NumLock           then KeyLocks := NumLock;
    If KeyLocks=ScrLock + CapLock           then KeyLocks := CapLock;
    If KeyLocks=ScrLock + CapLock + NumLock then KeyLocks := CapLock + NumLock;
  end;
  UpdateLocks;
end;

procedure SetNumlock;
begin
  if b=true then begin
    If KeyLocks=0                 then KeyLocks := NumLock;
    If KeyLocks=ScrLock           then KeyLocks := ScrLock + NumLock;
    If KeyLocks=CapLock           then KeyLocks := NumLock + CapLock;
    If KeyLocks=CapLock + ScrLock then KeyLocks := ScrLock + CapLock + NumLock;
  end;
  if b=false then begin
    If KeyLocks=NumLock                     then KeyLocks := 0;
    If KeyLocks=ScrLock + NumLock           then KeyLocks := ScrLock;
    If KeyLocks=NumLock + CapLock           then KeyLocks := CapLock;
    If KeyLocks=ScrLock + CapLock + NumLock then KeyLocks := CapLock + ScrLock;
  end;
  UpdateLocks;
end;

procedure SetCaplock;
begin
  if b=true then begin
    If KeyLocks=0                 then KeyLocks := CapLock;
    If KeyLocks=ScrLock           then KeyLocks := ScrLock + CapLock;
    If KeyLocks=NumLock           then KeyLocks := NumLock + CapLock;
    If KeyLocks=NumLock + ScrLock then KeyLocks := ScrLock + CapLock + NumLock;
  end;
  if b=false then begin
    If KeyLocks=CapLock                     then KeyLocks := 0;
    If KeyLocks=ScrLock + CapLock           then KeyLocks := ScrLock;
    If KeyLocks=NumLock + CapLock           then KeyLocks := NumLock;
    If KeyLocks=ScrLock + CapLock + NumLock then KeyLocks := NumLock + ScrLock;
  end;
  UpdateLocks;
end;

function GetScrLock;
begin
  if (KeyLocks=ScrLock) or
     (KeyLocks=ScrLock+NumLock) or
     (KeyLocks=ScrLock+CapLock) or
     (KeyLocks=ScrLock+NumLock+CapLock) then
       GetScrLock:=True else GetscrLock:=False;
end;

function GetNumLock;
begin
  if (KeyLocks=NumLock) or
     (KeyLocks=ScrLock+NumLock) or
     (KeyLocks=NumLock+CapLock) or
     (KeyLocks=ScrLock+NumLock+CapLock) then
       GetNumLock:=True else GetNumLock:=False;
end;

function GetCapLock;
begin
  if (KeyLocks=CapLock) or
     (KeyLocks=CapLock+NumLock) or
     (KeyLocks=ScrLock+CapLock) or
     (KeyLocks=ScrLock+NumLock+CapLock) then
       GetCapLock:=True else GetCapLock:=False;
end;


PROCEDURE Reboot;     
    VAR     dummy : Registers;
    BEGIN
        MemW[0:0] := 0;       
        MemW[0:2] := $FFFF;   
        Intr(0,dummy);        
    END;

PROCEDURE ColdBoot;           
BEGIN
  if bootlock=false then begin
    MemW[0:$472] := $7F7F;
    Reboot;
  end else fout(15);
end;

PROCEDURE WarmBoot;           
BEGIN
  if bootlock=false then begin
    MemW[0:$472] := $1234;
    Reboot;
  end else fout(15);
end;

Procedure Getchar;
begin
  c:=chr(mem[$B800:((x-1)+((y-1)*80))*2]);
end;

Procedure Putchar;
begin
  mem[$B800:((x-1)+((y-1)*80))*2]:=ord(c);
end;

var f:text;

begin
  if UltraPascal__Gemaakt_Door_Evert_Pot__1998_2001='' then writeln('Hacked!');
  fontinfo.bestand:='';
  fontinfo.bcversie:='';
  fontinfo.auteur:='';
  fontinfo.hoogte:=0;
  fontinfo.breedte:=0;
  fontinfo.naam:='';
  fontinfo.info:='';
  NRTmethode:=2;
  cursor:=true;
  bootlock:=true;
  ignore_errors:=false;
  UPfout:=0;
  checkfile('up4.nfo');
  if filefound then begin
    assign(f,'up4.nfo');
    rewrite(f);
    writeln(f,'UltraPascal 4.0 (c)1998-2001 by Evert Pot    info: WeirdEvert@Hotmail.com');
    close(f);
  end else writeln('UltraPascal 4.0  (c)1998-2001 by Evert Pot    info: WeirdEvert@Hotmail.com');
end.
