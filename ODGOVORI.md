## Zadatak 1 — Osnove Apache Cassandre
### 1. Koji port Cassandra eksponira i čemu služi?
Apache Cassandra zadano eksponira port **9042**. 
To je port za CQL (Cassandra Query Language) native transport. Kroz ovaj port komuniciraju svi moderni klijenti, upravljački programi (driveri za programski jezik Java, Python, C# itd.) i konzoli alati poput `cqlsh` kako bi slali upite bazi i primali podatke.

### 2. Zašto Cassandra nema ugrađeno web browser sučelje kao Neo4j?
Cassandra namjerno nema ugrađeno grafičko web sučelje (Web GUI) iz nekoliko ključnih arhitektonskih razloga:

- **Dizajn za masivno skaliranje (High Throughput):** Cassandra je projektirana da bude ekstremno brza, distribuirana baza podataka koja obrađuje milijune operacija u sekundi na stotinama čvorova (klastera). Ugrađivanje web poslužitelja i grafičkog sučelja u svaku instancu baze trošilo bi dragocjene CPU i RAM resurse, što se u produkcijskim sustavima smatra neprihvatljivim opterećenjem.
- **Filozofija "čistog backend sustava":** Za razliku od Neo4j baze (koja je graf baza i vizualni prikaz čvorova/veza joj je prirodna potreba), Cassandra pohranjuje podatke u obliku širokih tablica (Wide-Column Store). Za upravljanje njome sasvim su dovoljni brzi terminalski alati poput `cqlsh` ili vanjski alati (npr. *Datastax DevCenter* ili *DBeaver*) ako korisnik baš želi grafički prikaz.
- **Decentralizirana arhitektura (Peer-to-Peer):** S obzirom na to da u Cassandri svi čvorovi imaju jednaku ulogu (nema Master/Slave odnosa), pokretanje web sučelja na svakom pojedinačnom čvoru stvorilo bi nepotreban sigurnosni i mrežni rizik.


### 3. Zašto je izbor partition key-a kritičan u Cassandri i što je "hot partition" problem?
Izbor partition key-a je kritičan jer on određuje na koji će čvor u klasteru podaci biti spremljeni, što izravno utječe na ravnomjernu raspodjelu podataka i opterećenja u mreži. Ako svi zapisi imaju isti partition key, svi podaci završavaju na jednom jedinom čvoru, čime se stvara takozvani **"hot partition"** problem. To dovodi do preopterećenja tog specifičnog čvora (njegovog CPU-a i diska), dok ostali čvorovi u klasteru ostaju besposleni, što potpuno poništava prednosti Cassandrine distribuirane arhitekture i drastično ruši performanse sustava.

### Zadatak 4 — Analiza upita s ALLOW FILTERING
Upit koji koristi `ALLOW FILTERING` za pretraživanje po stupcu `status` je izrazito problematičan u produkciji jer taj stupac nije dio primarnog ključa (baza podatke ne organizira prema njemu). Cassandra je zbog toga prisiljena raditi "full table scan", odnosno mora kontaktirati sve čvorove u klasteru i pretražiti doslovno svaku particiju kako bi filtrirala podatke. Na velikim produkcijskim tablicama to troši goleme mrežne i procesorske resurse, drastično usporava bazu i može dovesti do rušenja cijelog sustava.

## Razlika između Partition Key i Clustering Column u WHERE upitima:
`Partition Key` (u našem slučaju `korisnik_id`) je primarni ključ koji određuje na kojem se fizičkom čvoru (particiji) unutar klastera nalaze podaci, i on je obvezan na početku WHERE upita kako bi Cassandra uopće znala gdje tražiti podatke. `Clustering Column` (u našem slučaju `created_at`) služi za fizičko sortiranje podataka unutar te jedne particije na disku, što nam omogućuje da radimo brze upite s rasponima (npr. `>=`) ili da mijenjamo smjer sortiranja pomoću `ORDER BY`.


### Zadatak 5 — Analiza brisanja i Tombstone markera
U Cassandri naredba `DELETE` ne briše podatak odmah s diska jer su njezine SSTable datoteke nepromjenjive (immutable), pa bi trenutno pretraživanje i prepisivanje datoteka drastično usporilo bazu. Umjesto toga, Cassandra preko obrisanog podatka postavlja posebnu oznaku zvanu **tombstone** (nadgrobni spomenik) koja sadrži timestamp brisanja i privremeno skriva podatak od upita. Ti se zapisi fizički uklanjaju s diska tek naknadno tijekom procesa **Compaction-a** (zbijanja), kada se stare SSTable datoteke spajaju u nove, ali samo ako je preostali životni vijek tombstonea premašio konfigurirano vrijeme `gc_grace_seconds`.


### Zadatak 6 — Analiza indeksiranja i materijaliziranih pogleda
Razlika između sekundarnog indeksa (Secondary Index) i materijaliziranog pogleda (Materialized View) leži u načinu pohrane i performansama:
1. **Secondary Index** je distribuiran lokalno na svakom čvoru koji drži primarne podatke. Prilikom upita, baza mora kontaktirati sve čvorove (scatter-gather operacija), što ga čini idealnim za stupce s niskom kardinalnošću (poput statusa ili kategorije), ali izuzetno sporim za stupce s mnogo jedinstvenih vrijednosti.
2. **Materialized View** automatski stvara i održava potpuno novu tablicu s drugačijim primarnim ključem u pozadini. Upiti su ekstremno brzi jer pogađaju samo jedan čvor koji je odgovoran za taj ključ, ali to dolazi uz cijenu "write amplifikacije" — svaki upis u originalnu tablicu zahtijeva dodatni skriveni upis u materijalizirani pogled.


### Usporedba: Secondary Index vs. Materialized View
**Secondary Index** koristimo kada želimo pretraživati tablicu po stupcima niske kardinalnosti (mali broj jedinstvenih vrijednosti), kao što je filtriranje artikala po stupcu `dostupnost` (true/false) ili narudžbi po stupcu `status`, jer indeks ne duplicira podatke već se pohranjuje lokalno na čvorovima. 
S druge strane, **Materialized View** (ili njegova zamjenska tablica) koristi se za stabilne i česte pristupne obrasce visokog intenziteta čitanja po stupcima visoke kardinalnosti, kao što je brza pretraga `narudzbe_po_statusu` ili po gradovima, jer kreira potpuno novu tablicu s novim primarnim ključem koja omogućuje direktan dohvat s točno određenog čvora bez pretraživanja cijelog klastera.


### Završni zadatak — Platforma za online tečajeve
#### 1. Objašnjenje dizajna ključeva (Primary Key)
- **Tablica tecaj**: Koristi `tecaj_id` kao jednostavni primarni ključ jer je svaki tečaj jedinstven entitet i podaci se traže izravno preko njegovog ID-a.
- **Tablica upis**: Koristi kompozitni ključ `PRIMARY KEY (student_id, tecaj_id)`. `student_id` je partition key, što znači da su svi upisi jednog studenta pohranjeni zajedno na istom mjestu na disku. To nam omogućuje da u trenu izvučemo popis svih tečajeva koje određeni student sluša.
- **Tablica lekcija**: Koristi kompozitni ključ `PRIMARY KEY (tecaj_id, redni_broj)`. Ovdje je `tecaj_id` partition key kako bi sve lekcije istog tečaja bile na istom čvoru, dok je `redni_broj` clustering key. To automatski sortira lekcije od prve prema zadnjoj unutar baze podataka.

#### 2. Kada koristiti Cassandru umjesto PostgreSQL-a na ovoj platformi?
Apache Cassandru bismo za platformu online tečajeva odabrali u trenutku kada sustav preraste u globalni servis (poput Udemyja ili Coursere) s milijunima aktivnih korisnika širom svijeta. Cassandra je idealna ako imamo ogroman broj istovremenih upisa (visoki write throughput) jer njezina arhitektura bez centralnog master čvora omogućuje linearno skaliranje i neprekidan rad sustava. Također, u situacijama kada stotine tisuća studenata istovremeno gledaju video lekcije i svake minute šalju podatke o svom napretku u bazi (npr. "odgledano 12%"), PostgreSQL bi doživio zagušenje zbog zaključavanja tablica i sinkronog zapisivanja na disk. Dodatno, problem automatskog brisanja probnih (trial) pristupa nakon 7 dana u Cassandri rješavamo jednostavno pomoću `USING TTL`, dok bi u PostgreSQL-u morali stalno vrtjeti teške pozadinske skripte i "cron" poslove koji opterećuju bazu brisanjem milijuna starih redaka.