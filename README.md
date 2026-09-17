# TMPT 10 UUR Garmin app

Connect IQ watch app voor meerdere ronde Garmin AMOLED-horloges.

Ondersteunde modellen in deze versie:

- Garmin Instinct 3 AMOLED 50 mm.
- Garmin Forerunner 265.
- Garmin Forerunner 965.
- Garmin Venu 3.
- Garmin vívoactive 5.

## Functies

- Telt vanaf de start continu door naar de daglimiet van 10 uur.
- Berekent gecorrigeerde tijd als verstreken tijd plus straftijd min officiële wachttijdcorrectie.
- Toont resterende tijd en kleurt geel onder 60 minuten en rood onder 15 minuten.
- Geeft een trilwaarschuwing bij 60, 30, 15 en 5 minuten en bij het verlopen van de limiet.
- Houdt strafrondes apart bij.
- Toont actuele hartslag, snelheid, gemiddelde snelheid en afstand.
- Slaat GPS, hartslag en activiteit op als Garmin FIT activiteit.
- Bewaart de timer en aanpassingen wanneer het scherm of de app opnieuw wordt geopend.

## Bediening

- START. Start de TMPT trainingsdag. Tijdens een actieve dag opent START het menu voor afronden.
- UP en DOWN. Wissel tussen tijd en live gegevens.
- MENU. Voeg straftijd, wachttijdcorrectie of een strafronde toe. Je kunt de laatste aanpassing ongedaan maken.
- BACK/SET. Opent tijdens een actieve dag het menu voor straftijd, wachttijdcorrectie en strafrondes.

## Belangrijke berekening

`gecorrigeerde tijd = verstreken tijd + straftijd - wachttijdcorrectie`

`resterend = 10 uur - gecorrigeerde tijd`

Strafrondes hebben geen vaste tijdswaarde. Daarom toont de app deze als apart aantal.

## Bouwen en testen

1. Installeer Visual Studio Code.
2. Installeer de officiële Garmin Monkey C extensie.
3. Installeer de Connect IQ SDK via de SDK Manager.
4. Open deze map in Visual Studio Code.
5. Maak via de opdracht `Monkey C: Generate a Developer Key` een ontwikkelaarscertificaat.
6. Open `source/TmptApp.mc`, druk op F5 en kies een ondersteund simulatormodel.
7. Test eerst starten, tijdcorrecties, afronden en FIT opslag in de simulator.

## Gebruik tijdens de echte TMPT

Gebruik de app tijdens het evenement alleen wanneer de TMPT organisatie hiervoor toestemming heeft gegeven.

Reglement. https://www.tmpt.nl/algemeen-en-huishoudelijk-reglement-2026
