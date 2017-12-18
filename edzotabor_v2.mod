set Edzesek;
param Napszam;
set Napok:= 1..Napszam;

param Szabadido{Napok};
param BeoltozesiIdo{Edzesek};
param MinIdo{Edzesek};
param Koltsegek{Edzesek};
param maxFutojatekKoltseg;
param tagSzam;
param maxEgyFoKoltseg;

param ef1, symbolic;
param ef2, symbolic;
param ef3, symbolic;
param ef4, symbolic;
param ef5, symbolic;
param ef6, symbolic;
param ef7, symbolic;

#v�ltoz�k 
var edzesselToltottIdo{Edzesek};
var melyikEdzesMelyikNap{Edzesek,Napok}, binary;
var osszKoltsegek{Edzesek};

#korl�toz�sok

#egy nap legfeljebb csak egyfajta edz�s v�gezhet�
s.t. EgyNapEgyFajtaEdzes {n in Napok}:
	sum{e in Edzesek} melyikEdzesMelyikNap[e,n] <= 1;

#csak aznap v�gezhet� edz�s, amikor van r� id�
s.t. EdzesAkkorHaVanIdo{e in Edzesek, n in Napok}:
	melyikEdzesMelyikNap[e,n] * BeoltozesiIdo[e] <= Szabadido[n];

#egym�st k�vet� napon nem v�gezhet� ugyanaz
s.t. NemVegezhetuUgyanAzEgymasUtan{n in 1..Napszam-1, e in Edzesek}:
	melyikEdzesMelyikNap[e,n] + melyikEdzesMelyikNap[e,n+1] <= 1;

#a k�l�nb�z� edz�sfajt�kkal t�lt�tt id�
s.t. AzEdzesekkelToltottIdo{e in Edzesek}:
	sum{n in Napok} (melyikEdzesMelyikNap[e,n] * (Szabadido[n]-BeoltozesiIdo[e])) = edzesselToltottIdo[e];

#minden edz�ssel legal�bb annyit kell foglalkozni, mint a megadott id�
s.t. LegalabbAnnyiIdoMintAmennyiMegVanAdva{e in Edzesek}:
	edzesselToltottIdo[e] >= MinIdo[e];

#kontaktos napot k�vet� napon mindenk�pp vide�z�s kell, hogy legyen amennyiben aznap v�gz�nk edz�st (nem lehet m�sik edz�s)
s.t. KontaktUtanVideozas{n in 1..Napszam-1}:
	melyikEdzesMelyikNap[ef7,n] + melyikEdzesMelyikNap[ef1,n+1] + melyikEdzesMelyikNap[ef2,n+1] + melyikEdzesMelyikNap[ef3,n+1] + melyikEdzesMelyikNap[ef4,n+1] + melyikEdzesMelyikNap[ef6,n+1] <= 1;

# a konditerem a 20, �s 27, nap k�z�tt z�rva van �talak�t�s miatt
s.t. KonditeremZarva{n in 20..27}:
	melyikEdzesMelyikNap[ef1,n] = 0; 

#�sszek�lts�gek
s.t. KoltsegSzamitas{e in Edzesek}:
	sum{n in Napok} (melyikEdzesMelyikNap[e,n] * Koltsegek[e]) = osszKoltsegek[e];

#fut�j�t�k k�lts�ge maximum 30ezer legyen
s.t. NeLegyenTobbMint:
	osszKoltsegek[ef2] <= maxFutojatekKoltseg;

#Az egy f�re jut� k�lts�g maximum 3000 Ft legyen
s.t. EgyForeJutoKoltseg:
	(osszKoltsegek[ef1] + osszKoltsegek[ef2] + osszKoltsegek[ef3] + osszKoltsegek[ef4] + osszKoltsegek[ef5] + osszKoltsegek[ef6] + osszKoltsegek[ef7]) / tagSzam <= maxEgyFoKoltseg;

#c�lf�ggv�ny
maximize JatekTervBetanulasavalToltottIdo: sum{n in Napok} (melyikEdzesMelyikNap[ef2,n] + melyikEdzesMelyikNap[ef3,n]);

solve;
printf"\nA jatekterv betanulas�val toltott ido: %d nap\n\n",JatekTervBetanulasavalToltottIdo;
printf"Adott edzeseket a kovetkezo napokon vegzi a csapat:\n";
for{e in Edzesek}{
	printf"%s: ",e;
	for{n in Napok: melyikEdzesMelyikNap[e,n]=1}{
		printf"%d ",n;
	}
	printf"\n";
}
printf"\n";
for{e in Edzesek}{
	printf"%s edzessel toltott ido mennyisege: %.1f\n",e,edzesselToltottIdo[e];
}
printf"\n";
for{e in Edzesek}{
	printf"%s edzes koltsege: %d Ft\n",e,osszKoltsegek[e];
}
printf"\n";
printf"A teljes edzotabor koltsege: %d Ft\n",osszKoltsegek[ef1] + osszKoltsegek[ef2] + osszKoltsegek[ef3] + osszKoltsegek[ef4] + osszKoltsegek[ef5] + osszKoltsegek[ef6] + osszKoltsegek[ef7];
printf"Egy fore juto koltseg: %.2f Ft\n\n",(osszKoltsegek['Konditerem'] + osszKoltsegek['Futojatek'] + osszKoltsegek['Passzjatek'] + osszKoltsegek['Specialis_csapat'] + osszKoltsegek['Videozas'] + osszKoltsegek['Kontaktnelkuli'] + osszKoltsegek['Kontakt']) / tagSzam;

end;