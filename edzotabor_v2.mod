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

#változók 
var edzesselToltottIdo{Edzesek};
var melyikEdzesMelyikNap{Edzesek,Napok}, binary;
var osszKoltsegek{Edzesek};

#korlátozások

#egy nap legfeljebb csak egyfajta edzés végezhetõ
s.t. EgyNapEgyFajtaEdzes {n in Napok}:
	sum{e in Edzesek} melyikEdzesMelyikNap[e,n] <= 1;

#csak aznap végezhetõ edzés, amikor van rá idõ
s.t. EdzesAkkorHaVanIdo{e in Edzesek, n in Napok}:
	melyikEdzesMelyikNap[e,n] * BeoltozesiIdo[e] <= Szabadido[n];

#egymást követõ napon nem végezhetõ ugyanaz
s.t. NemVegezhetuUgyanAzEgymasUtan{n in 1..Napszam-1, e in Edzesek}:
	melyikEdzesMelyikNap[e,n] + melyikEdzesMelyikNap[e,n+1] <= 1;

#a különbözõ edzésfajtákkal töltött idõ
s.t. AzEdzesekkelToltottIdo{e in Edzesek}:
	sum{n in Napok} (melyikEdzesMelyikNap[e,n] * (Szabadido[n]-BeoltozesiIdo[e])) = edzesselToltottIdo[e];

#minden edzéssel legalább annyit kell foglalkozni, mint a megadott idõ
s.t. LegalabbAnnyiIdoMintAmennyiMegVanAdva{e in Edzesek}:
	edzesselToltottIdo[e] >= MinIdo[e];

#kontaktos napot követõ napon mindenképp videózás kell, hogy legyen amennyiben aznap végzünk edzést (nem lehet másik edzés)
s.t. KontaktUtanVideozas{n in 1..Napszam-1}:
	melyikEdzesMelyikNap[ef7,n] + melyikEdzesMelyikNap[ef1,n+1] + melyikEdzesMelyikNap[ef2,n+1] + melyikEdzesMelyikNap[ef3,n+1] + melyikEdzesMelyikNap[ef4,n+1] + melyikEdzesMelyikNap[ef6,n+1] <= 1;

# a konditerem a 20, és 27, nap között zárva van átalakítás miatt
s.t. KonditeremZarva{n in 20..27}:
	melyikEdzesMelyikNap[ef1,n] = 0; 

#összeköltségek
s.t. KoltsegSzamitas{e in Edzesek}:
	sum{n in Napok} (melyikEdzesMelyikNap[e,n] * Koltsegek[e]) = osszKoltsegek[e];

#futójáték költsége maximum 30ezer legyen
s.t. NeLegyenTobbMint:
	osszKoltsegek[ef2] <= maxFutojatekKoltseg;

#Az egy fõre jutó költség maximum 3000 Ft legyen
s.t. EgyForeJutoKoltseg:
	(osszKoltsegek[ef1] + osszKoltsegek[ef2] + osszKoltsegek[ef3] + osszKoltsegek[ef4] + osszKoltsegek[ef5] + osszKoltsegek[ef6] + osszKoltsegek[ef7]) / tagSzam <= maxEgyFoKoltseg;

#célfüggvény
maximize JatekTervBetanulasavalToltottIdo: sum{n in Napok} (melyikEdzesMelyikNap[ef2,n] + melyikEdzesMelyikNap[ef3,n]);

solve;
printf"\nA jatekterv betanulasával toltott ido: %d nap\n\n",JatekTervBetanulasavalToltottIdo;
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