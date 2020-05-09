Program MASTER_MIND;

Uses crt,dos,graph;

Type jeu = array [0..9] of shortint;

Var  cache,joueur : jeu;
     col,coul     : byte;
     touche       : char;
     i,j,coup     : integer;
     fin,ok       : boolean;
     ch           : string[2];

Const couleurs : jeu
               = (black,lightred,green,lightblue,yellow,
                  magenta,lightcyan,brown,lightgray,darkgray);

Procedure VIDE_BUFFER_CLAVIER;
var  regs : registers;
begin
    regs.ax:=$0C00;
    MsDos(regs);
end;

Procedure CURSEUR(ok : boolean);
var    Reg       : registers;
       NoCurseur : word;
begin
  NoCurseur:= $0207;
  Reg.Ax := $100;
  if ok then Reg.Cx := NoCurseur else Reg.Cx:=$F0F0;
  Intr($10,Reg)
end;

Procedure INIT_GRAPH;
var driver,mode,err : Integer;
begin
 Clrscr;
 Writeln;
 Vide_Buffer_Clavier;
 DetectGraph(Driver,Mode);
 if (Driver<>VGA) or (Mode<>VGAHi) then
 begin
   Writeln(' Ce programme nécessite un écran VGA');
   Write(' en mode 640x480, 16 couleurs.');
   repeat until keypressed;
   halt;
 end;
 InitGraph(Driver,Mode,' '); { Mettre ici le chemin des BGI }
 Err := GraphResult;
 if not Err = grOk then
   begin
     Writeln('Erreur d''initialisation graphique : ');
     Write(GraphErrorMsg(Err));
     repeat until keypressed;
     halt;
   end;
end;

Procedure APROPOS;
Begin
TextMode(CO80);
TextBackGround(blue);
TextColor(LightGreen);
ClrScr;
Curseur(False);
Writeln('Master Mind, programm‚ en juillet 199x.');
Writeln('Ce jeu est un FREEWARE.');
Writeln;
TextColor(Yellow);
Writeln('Règle du jeu : le but est de retrouver la combinaison cachée composée de');
Writeln('plusieurs colonnes, chacune correspondant à un pion d''une couleur.');
Writeln;
Writeln('Comment jouer :');
Writeln('* Choisissez le nombre de colonnes de la combinaison cachée, ainsi que le');
Writeln('  nombre de couleurs possibles (une couleur peut intervenir plusieurs fois).');
Writeln('* Choisissez la colonne à modifier avec les touches 4 et 6 du pavé numérique,');
Writeln('  ou les touches gauche et droite du curseur.');
Writeln('* Choisissez alors la couleur du pion avec les touches 2 et 8 du pavé');
Writeln('  numérique, ou les touches Bas et Haut du curseur.');
Writeln('* Quand toutes les colonnes ont un pion (il ne peut pas y avoir de colonne');
Writeln('  vide), appuyez sur Entrée pour valider la ligne.');
Writeln('* Les petits pions noirs sur la droite indiquent les pions de votre proposition');
Writeln('  bien placés, les blancs indiquent les couleurs existantes mais mal placées');
Writeln('  La position des pions noirs et blancs ne correspond pas avec celle');
Writeln('  des pions de couleurs de votre suggestion.');
Writeln('* Si vous trouvez avant les 14 essais, vous avez gagné (sinon...).');
Writeln('* Si vous en avez marre avant la fin, quittez avec Esc.');
TextColor(Green);
Writeln;
Writeln('Appuyez sur une touche pour continuer...');
Vide_Buffer_Clavier;
Repeat until keypressed;
Curseur(true);
Init_Graph;
End;

Procedure CADRE(posx,posy:integer;couleur:byte);
Begin
  posx:=35*posx+20;
  posy:=30*posy+13;
  setcolor(couleur);
  rectangle(posx-14,posy-14,posx+14,posy+14);
end;

Procedure AFFICHE_PION(posx,posy:integer;couleur:byte);
Begin
  posx:=35*posx+20;
  posy:=30*posy+13;
  setcolor(couleurs[couleur]);
  circle(posx,posy,12);
  setfillstyle(1,couleurs[couleur]);
  floodfill(posx+3,posy+3,couleurs[couleur]);
  If couleur<>0 then
    Begin
      Setcolor(white);
      circle(posx-3,posy-3,4);
      setfillstyle(1,white);
      floodfill(posx-3,posy-3,white);
    end;
end;

Procedure PLACE_PRESENT;
Var temp  : jeu;
    pl,pr : byte;
Begin
  Cadre(i,coup,black);
  pl:=0;
  pr:=0;
  temp:=cache;
{ Recherche des pions bien plac‚s }
  For i:=1 to col do
    if joueur[i]=temp[i] then
      begin
        inc(pl);
        joueur[i]:=0; { On efface les pions pour ne pas les compter placés }
        temp[i]:=0;
      end;
{ Recherche des pions présents mal placés }
  For i:=1 to col do
    For j:=1 to col do
      if (joueur[i]=temp[j]) and (joueur[i]<>0) then
        begin
          inc(pr);
          temp[j]:=0;
          j:=col;
        end;
{ Mise en place des pions résultat }
  setcolor(darkgray);
  if pl>0 then
    for i:=1 to pl do
      Begin
        circle(25*i+35*col+60,30*coup+13,5);
        SetFillStyle(1,darkgray);
        FloodFill(25*i+35*col+60,30*coup+13,darkgray);
      end;
  setcolor(white);
  if pr>0 then
    for i:=pl+1 to pl+pr do
      begin
        circle(25*i+35*col+60,30*coup+13,5);
        SetFillStyle(1,white);
        FloodFill(25*i+35*col+60,30*coup+13,white);
      end;
  for i:=1 to col do joueur[i]:=0;
  if pl<>col then dec(coup) else fin:=true;
  i:=1;
  if (coup>1) and (pl<col) then cadre(i,coup,white);
  vide_buffer_clavier;
end;

BEGIN { Programme Principal }
{ Initialisation systême graphique }
 Init_graph;
{ Ecran de présentation et demande des paramètres }
 ClearViewPort;
 vide_buffer_clavier;
 settextstyle(triplexfont,horizdir,6);
 setcolor(lightblue);
 OutTextXY(80,40,'Master Mind');
 setcolor(white);
 OutTextXY(80,140,'Lire la doc (O)ui/(N)on ?');
 repeat
   repeat until keypressed;
   touche:=upcase(readkey);
 until (touche='O') or (touche='N');
 If touche='O' then
   Begin
     Apropos;
     ClearViewPort;
     settextstyle(triplexfont,horizdir,6);
     setcolor(lightblue);
     OutTextXY(80,40,'Master Mind');
     setcolor(white);
     OutTextXY(80,140,'Lire la doc (O)ui/(N)on ?');
   end;
 vide_buffer_clavier;
 OutTextXY(80,220,'Nombre de colonnes (3..9) ?');
 repeat
   repeat until keypressed;
   touche:=readkey;
 until (ord(touche)>50) and (ord(touche)<58);
 val(touche,col,i);
 OutTextXY(550,220,touche);
 vide_buffer_clavier;
 OutTextXY(80,300,'Nombre de couleurs (3..9) ?');
 repeat
   repeat until keypressed;
   touche:=readkey;
 until (ord(touche)>50) and (ord(touche)<58);
 val(touche,coul,i);
 OutTextXY(550,300,touche);
 clearviewport;
{ Tirage aléatoire de la combinaison cachée }
 randomize;
 For i:=1 to col do cache[i]:=random(coul)+1;
{ Initialisation des variables }
 Setcolor(cyan);
 OutTextXY(430,3,'Master Mind');
 settextstyle(triplexfont,horizdir,3);
 OutTextXY(430,30,'Version 1.0');
 SetColor(White);
 For coup:=15 downto 2 do
   Begin
     str(16-coup,ch);
     OuttextXY(3,30*coup-3,ch);
   end;
 coup:=15;
 fin:=false;
 for i:=1 to col do joueur[i]:=0;
 i:=1;
 cadre(i,coup,white);
{ Début du jeu }
 repeat
   ok:=false;
   repeat until keypressed;
   touche:=readkey;
   Case touche of  #27     : Begin
                               CloseGraph;
                               LowVideo;
                               TextMode(BW80);
                               halt(1);
                             End;
                   #72,'8' : begin
                               inc(joueur[i]);
                               if joueur[i]>coul then joueur[i]:=0;
                               Affiche_pion(i,coup,joueur[i]);
                             end;
                   #80,'2' : begin
                               dec(joueur[i]);
                               if joueur[i]<0 then joueur[i]:=coul;
                               Affiche_pion(i,coup,joueur[i]);
                             end;
                   #77,'6' : Begin
                               Cadre(i,coup,black);
                               inc(i);
                               if i>col then i:=1;
                               Cadre(i,coup,white);
                             end;
                   #75,'4' : Begin
                               Cadre(i,coup,black);
                               dec(i);
                               if i<1 then i:=col;
                               Cadre(i,coup,white);
                             end;
                   #13     : Begin
                               ok:=true;
                               for j:=1 to col do
                                 if joueur[j]=0 then ok:=false;
                             end;
   end;
   if ok then Place_Present;
 until (coup=1) or fin;
{ Fin de la partie }
 For i:=1 to col do Affiche_pion(i,0,cache[i]);
 vide_buffer_clavier;
 SetTextStyle(SansSerifFont,horizdir,3);
 Setcolor(green);
 OutTextXY(50,28,'solution');
 setcolor(lightblue);
 rectangle(390,205,618,242);
 SetFillStyle(1,white);
 FloodFill(400,220,lightblue);
 if (coup=1) then OutTextXY(400,207, 'Bouuuh : perdu !!')
             else OutTextXY(400,207,'Vous avez gagné !');
 vide_buffer_clavier;
 repeat until keypressed;
 CloseGraph;
 LowVideo;
 TextMode(BW80);
END.
