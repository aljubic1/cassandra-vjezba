-- ====================================================================
-- APACHE CASSANDRA —  VJEŽBA
-- ====================================================================

-- ====================================================================
-- KORAK 1 & 2 — STVARANJE BAZA I TABLICA
-- ====================================================================

-- Stvaramo prostor za našu vježbu (bazu podataka)
CREATE KEYSPACE IF NOT EXISTS vjezba
  WITH replication = {
    'class': 'SimpleStrategy',
    'replication_factor': 1
  };

-- Ulazimo u tu bazu kako bi radili u njoj
USE vjezba;

-- Tablica za narudžbe kupaca
CREATE TABLE narudzbe (
  korisnik_id UUID,
  created_at  TIMESTAMP,
  narudzba_id UUID,
  ukupno      DECIMAL,
  status      TEXT,
  grad        TEXT,
  PRIMARY KEY (korisnik_id, created_at)
) WITH CLUSTERING ORDER BY (created_at DESC);

-- Tablica u kojoj stoje naši proizvodi
CREATE TABLE proizvodi (
  id          UUID PRIMARY KEY,
  naziv       TEXT,
  cijena      DECIMAL,
  kategorija  TEXT,
  dostupnost  BOOLEAN
);

-- Tablica za recenzije i ocjene proizvoda
CREATE TABLE recenzije (
  proizvod_id UUID,
  korisnik_id UUID,
  ocjena      INT,
  komentar    TEXT,
  created_at  TIMESTAMP,
  PRIMARY KEY (proizvod_id, korisnik_id)
);

-- Naša dodatna tablica: Praćenje koji je korisnik gledao koji proizvod i kada
CREATE TABLE pregledi_proizvoda (
  korisnik_id      UUID,
  vrijeme_pregleda TIMESTAMP,
  proizvod_id      UUID,
  trajanje_sekundi INT,
  PRIMARY KEY (korisnik_id, vrijeme_pregleda)
) WITH CLUSTERING ORDER BY (vrijeme_pregleda DESC);


-- ====================================================================
-- KORAK 3 — UPISIVANJE PODATAKA
-- ====================================================================

-- Upisujemo 6 osnovnih artikala u trgovinu
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (ccd3a17c-a63f-4dff-aa46-7c4dafe278cd, 'Laptop Pro 15', 1299.99, 'elektronika', true);
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (8e2d6c70-ba9f-49aa-860f-4734cf340541, 'Bežične slušalice', 149.99, 'elektronika', true);
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (ab309fd9-9c7e-4e30-8c86-73b77f7764e7, 'Ergonomska stolica', 349.00, 'namještaj', true);
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (aa71f66a-999a-4634-8517-2553ffcb9e10, 'Mehanička tipkovnica', 89.99, 'elektronika', false);
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (0e125128-b56b-49d7-8934-4a096410e2cf, 'Monitor 27"', 499.00, 'elektronika', true);
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (9c7351c1-8ae0-4bea-88d4-5e2d52846e69, 'Radni stol', 279.00, 'namještaj', true);

-- Narudžbe za Korisnika A
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 1449.98, 'isporuceno', 'Zagreb');
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 349.00, 'u_obradi', 'Zagreb');
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (11111111-1111-1111-1111-111111111111, toTimestamp(now()), uuid(), 89.99, 'isporuceno', 'Zagreb');

-- Narudžbe za Korisnika B
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (22222222-2222-2222-2222-222222222222, toTimestamp(now()), uuid(), 499.00, 'isporuceno', 'Split');
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (22222222-2222-2222-2222-222222222222, toTimestamp(now()), uuid(), 279.00, 'otkazano', 'Split');

-- Upisujemo recenzije i dojmove za proizvode
INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at) VALUES (ccd3a17c-a63f-4dff-aa46-7c4dafe278cd, 11111111-1111-1111-1111-111111111111, 5, 'Odlican laptop, brz i tih.', toTimestamp(now()));
INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at) VALUES (ccd3a17c-a63f-4dff-aa46-7c4dafe278cd, 22222222-2222-2222-2222-222222222222, 4, 'Dobra kupnja, baterija mogla bolja.', toTimestamp(now()));
INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at) VALUES (ab309fd9-9c7e-4e30-8c86-73b77f7764e7, 11111111-1111-1111-1111-111111111111, 5, 'Spasila mi je leda!', toTimestamp(now()));

-- Moje 3 narudžbe za trećeg korisnika u različitim gradovima (Zadatak 3)
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (33333333-3333-3333-3333-333333333333, '2026-05-25 12:00:00+0000', uuid(), 150.00, 'u_obradi', 'Mostar');
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 45.50, 'isporuceno', 'Sarajevo');
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 620.00, 'isporuceno', 'Banja Luka');

-- Test za UPSERT (Ako unesemo isto vrijeme za Mostar, Cassandra samo prepiše stari iznos novim)
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (33333333-3333-3333-3333-333333333333, '2026-05-25 12:00:00+0000', uuid(), 888.88, 'u_obradi', 'Mostar');


-- ====================================================================
-- KORAK 4 — PRETRAŽIVANJE PODATAKA (UPITI)
-- ====================================================================

-- Tražimo sve narudžbe za Korisnika A
SELECT korisnik_id, created_at, ukupno, status FROM narudzbe WHERE korisnik_id = 11111111-1111-1111-1111-111111111111;

-- Tražimo narudžbe Korisnika A, ali samo one od 2024. godine naovamo
SELECT * FROM narudzbe WHERE korisnik_id = 11111111-1111-1111-1111-111111111111 AND created_at >= '2024-01-01 00:00:00+0000';

-- Uzimamo samo prve 2 narudžbe za Korisnika A
SELECT * FROM narudzbe WHERE korisnik_id = 11111111-1111-1111-1111-111111111111 LIMIT 2;

-- Izlistaj sve proizvode iz trgovine
SELECT naziv, cijena, kategorija, dostupnost FROM proizvodi;

-- Službeni upit: Narudžbe mog korisnika poslagane od NAJSTARIJE (obrnuto od zadanog)
SELECT korisnik_id, created_at, narudzba_id, ukupno, status, grad FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333 ORDER BY created_at ASC;

-- Službeni upit: Tražimo isporučene narudžbe preko cijele baze (mora se dodati ALLOW FILTERING)
SELECT * FROM narudzbe WHERE status = 'isporuceno' ALLOW FILTERING;

-- Test za TTL: Narudžba koja samu sebe briše iz baze nakon pola minute (30 sekundi)
INSERT INTO narudzbe (korisnik_id, created_at, narudzba_id, ukupno, status, grad) VALUES (33333333-3333-3333-3333-333333333333, toTimestamp(now()), uuid(), 19.99, 'ttl_30_sekundi', 'Mostar') USING TTL 30;
SELECT TTL(status), status, grad FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;


-- ====================================================================
-- KORAK 5 — PROMJENE, BRISANJE I TRANSAKCIJE (LWT)
-- ====================================================================

-- Službeni upit: Mijenjamo status narudžbe iz 'u_obradi' u 'isporuceno'
UPDATE narudzbe SET status = 'isporuceno' WHERE korisnik_id = 33333333-3333-3333-3333-333333333333 AND created_at = '2026-05-25 12:00:00.000000+0000';
SELECT korisnik_id, created_at, status, grad FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- Službeni upit: Pokušavamo dodati proizvod s ID-em koji već postoji (Baza javlja [applied] = false)
INSERT INTO proizvodi (id, naziv, cijena, kategorija, dostupnost) VALUES (ccd3a17c-a63f-4dff-aa46-7c4dafe278cd, 'Lazni Monitor', 99.99, 'elektronika', true) IF NOT EXISTS;

-- Službeni upit: Brišemo narudžbu za Mostar i provjeravamo da je nema u bazi
DELETE FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333 AND created_at = '2026-05-25 12:00:00.000000+0000';
SELECT korisnik_id, created_at, status, grad FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;

-- Brisanje samo teksta komentara iz jedne recenzije (ostatak retka ostaje sačuvan)
DELETE komentar FROM recenzije WHERE proizvod_id = ccd3a17c-a63f-4dff-aa46-7c4dafe278cd AND korisnik_id = 11111111-1111-1111-1111-111111111111;

-- Izvršavanje više naredbi spojenih u jedan zajednički paket (BATCH)
BEGIN BATCH
  INSERT INTO recenzije (proizvod_id, korisnik_id, ocjena, komentar, created_at) VALUES (ccd3a17c-a63f-4dff-aa46-7c4dafe278cd, 22222222-2222-2222-2222-222222222222, 5, 'Odlicna rezolucija.', toTimestamp(now()));
  UPDATE recenzije SET ocjena = 5 WHERE proizvod_id = ccd3a17c-a63f-4dff-aa46-7c4dafe278cd AND korisnik_id = 22222222-2222-2222-2222-222222222222;
APPLY BATCH;


-- ====================================================================
-- KORAK 6 — INDEKSI, ZAMJENA ZA POGLEDE I RAČUNANJA (AGREGACIJE)
-- ====================================================================

-- Službeni upit: Kreiramo indeks za dostupnost kako bi pretraga radila bez ALLOW FILTERING
CREATE INDEX idx_dostupnost ON proizvodi (dostupnost);
SELECT id, naziv, cijena FROM proizvodi WHERE dostupnost = true;

-- ====================================================================
-- OBJAŠNJENJE (ZAOBILAZAK ZA MATERIALIZED VIEW):
-- Budući da naša verzija baze (Cassandra 5) ima tvornički ugašenu opciju
-- za "Materialized View", umjesto toga smo napravili novu pravu tablicu
-- 'narudzbe_po_statusu' uz malu pomoć AI alata. Ona služi za izuzetno brzu pretragu po statusu
-- i radi potpuno istu stvar na disku kao i pravi pogled (View).
-- ====================================================================
CREATE TABLE narudzbe_po_statusu (
  status      TEXT,
  korisnik_id UUID,
  created_at  TIMESTAMP,
  grad        TEXT,
  ukupno      DECIMAL,
  PRIMARY KEY (status, korisnik_id, created_at)
);

-- Upisujemo testni podatak i provjeravamo brzu pretragu po statusu
INSERT INTO narudzbe_po_statusu (status, korisnik_id, created_at, grad, ukupno) VALUES ('isporuceno', 33333333-3333-3333-3333-333333333333, '2026-05-25 09:05:23.000000+0000', 'Sarajevo', 150.00);
SELECT * FROM narudzbe_po_statusu WHERE status = 'isporuceno';

-- Službeni upit: Računamo ukupnu potrošnju (SUM) i prosjek (AVG) za mog trećeg korisnika
SELECT SUM(ukupno) AS ukupna_potrosnja, AVG(ukupno) AS prosjecni_iznos FROM narudzbe WHERE korisnik_id = 33333333-3333-3333-3333-333333333333;


-- ====================================================================
-- KORAK 7 — PREGLED KRAJNJEG STANJA
-- ====================================================================

-- Naredbe za provjeru i ispis cijele baze na kraju rada
DESCRIBE KEYSPACE vjezba;
DESCRIBE TABLES;



-- ====================================================================
-- ZAVRŠNI ZADATAK — PLATFORMA ZA ONLINE TEČAJEVE
-- ====================================================================

-- 1. Kreiranje tablice TEČAJ (Pohrana podataka o tečajevima)
CREATE TABLE tecaj (
  tecaj_id      UUID PRIMARY KEY,
  naziv         TEXT,
  instruktor    TEXT,
  kategorija    TEXT,
  cijena        DECIMAL,
  trajanje_sati INT
);

-- 2. Kreiranje tablice UPIS (Koji je student upisao koji tečaj)
CREATE TABLE upis (
  student_id  UUID,
  tecaj_id    UUID,
  datum_upisa TIMESTAMP,
  napredak    INT,
  status      TEXT,
  PRIMARY KEY (student_id, tecaj_id)
);

-- 3. Kreiranje tablice LEKCIJA (Lekcije unutar tečajeva, sortirane po broju)
CREATE TABLE lekcija (
  tecaj_id      UUID,
  redni_broj    INT,
  naslov        TEXT,
  trajanje_min  INT,
  sadrzaj_url   TEXT,
  PRIMARY KEY (tecaj_id, redni_broj)
) WITH CLUSTERING ORDER BY (redni_broj ASC);


-- ====================================================================
-- UNOS PODATAKA (5 Tečajeva, 10 Upisa, 15 Lekcija)
-- ====================================================================

-- Unos 5 tečajeva
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati) VALUES (10000000-1000-1000-1000-100000000000, 'Uvod u Python', 'Ana Anic', 'Programiranje', 49.99, 20);
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati) VALUES (20000000-2000-2000-2000-200000000000, 'Napredni Java tecaj', 'Ivan Ivic', 'Programiranje', 89.99, 35);
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati) VALUES (30000000-3000-3000-3000-300000000000, 'Osnove Web Dizajna', 'Marija Maric', 'Dizajn', 39.99, 15);
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati) VALUES (40000000-4000-4000-4000-400000000000, 'Uvod u SQL baze', 'Petar Petric', 'Baze podataka', 59.99, 18);
INSERT INTO tecaj (tecaj_id, naziv, instruktor, kategorija, cijena, trajanje_sati) VALUES (50000000-5000-5000-5000-500000000000, 'UI/UX za pocetnike', 'Marija Maric', 'Dizajn', 69.99, 22);

-- Unos 10 upisa (za 3 različita studenta: Student 111..., Student 222..., Student 333...)
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (11111111-1111-1111-1111-111111111111, 10000000-1000-1000-1000-100000000000, toTimestamp(now()), 80, 'aktivan');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (11111111-1111-1111-1111-111111111111, 30000000-3000-3000-3000-300000000000, toTimestamp(now()), 100, 'zavrseno');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (11111111-1111-1111-1111-111111111111, 40000000-4000-4000-4000-400000000000, toTimestamp(now()), 25, 'aktivan');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (22222222-2222-2222-2222-222222222222, 10000000-1000-1000-1000-100000000000, toTimestamp(now()), 10, 'aktivan');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (22222222-2222-2222-2222-222222222222, 20000000-2000-2000-2000-200000000000, toTimestamp(now()), 50, 'aktivan');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (22222222-2222-2222-2222-222222222222, 50000000-5000-5000-5000-500000000000, toTimestamp(now()), 0, 'aktivan');

INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (33333333-3333-3333-3333-333333333333, 20000000-2000-2000-2000-200000000000, toTimestamp(now()), 90, 'aktivan');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (33333333-3333-3333-3333-333333333333, 30000000-3000-3000-3000-300000000000, toTimestamp(now()), 15, 'aktivan');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (33333333-3333-3333-3333-333333333333, 40000000-4000-4000-4000-400000000000, toTimestamp(now()), 100, 'zavrseno');
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (33333333-3333-3333-3333-333333333333, 50000000-5000-5000-5000-500000000000, toTimestamp(now()), 60, 'aktivan');

-- Unos 15 lekcija (po 3 lekcije za svaki od 5 tečajeva)
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (10000000-1000-1000-1000-100000000000, 1, 'Instalacija Pythona', 10, 'http://link.com/p1');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (10000000-1000-1000-1000-100000000000, 2, 'Varijable i tipovi', 15, 'http://link.com/p2');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (10000000-1000-1000-1000-100000000000, 3, 'Petlje i uvjeti', 20, 'http://link.com/p3');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (20000000-2000-2000-2000-200000000000, 1, 'OOP u Javi', 25, 'http://link.com/j1');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (20000000-2000-2000-2000-200000000000, 2, 'Kolekcije i liste', 30, 'http://link.com/j2');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (20000000-2000-2000-2000-200000000000, 3, 'Rad s iznimkama', 20, 'http://link.com/j3');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (30000000-3000-3000-3000-300000000000, 1, 'Uvod u HTML', 12, 'http://link.com/d1');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (30000000-3000-3000-3000-300000000000, 2, 'Osnove CSS-a', 18, 'http://link.com/d2');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (30000000-3000-3000-3000-300000000000, 3, 'Flexbox raspored', 22, 'http://link.com/d3');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (40000000-4000-4000-4000-400000000000, 1, 'Kreiranje tablica', 15, 'http://link.com/s1');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (40000000-4000-4000-4000-400000000000, 2, 'SELECT i filtriranje', 20, 'http://link.com/s2');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (40000000-4000-4000-4000-400000000000, 3, 'Spajanje tablica (JOIN)', 25, 'http://link.com/s3');

INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (50000000-5000-5000-5000-500000000000, 1, 'Sto je UI, a sto UX?', 15, 'http://link.com/ux1');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (50000000-5000-5000-5000-500000000000, 2, 'Zakonitosti dizajna', 20, 'http://link.com/ux2');
INSERT INTO lekcija (tecaj_id, redni_broj, naslov, trajanje_min, sadrzaj_url) VALUES (50000000-5000-5000-5000-500000000000, 3, 'Izrada prototipa', 30, 'http://link.com/ux3');


-- ====================================================================
-- OBAVEZNI SELECT, UPDATE I TTL UPITI
-- ====================================================================

-- Upit 1: Sve lekcije iz 'Uvoda u Python' sortirane automatski po rednom broju
SELECT * FROM lekcija WHERE tecaj_id = 10000000-1000-1000-1000-100000000000;

-- Upit 2: Svi tečajevi koje sluša Student 111...
SELECT * FROM upis WHERE student_id = 11111111-1111-1111-1111-111111111111;

-- Upit 3: Ažuriranje napretka Studenta 111... za Python tečaj na 85%
UPDATE upis SET napredak = 85 WHERE student_id = 11111111-1111-1111-1111-111111111111 AND tecaj_id = 10000000-1000-1000-1000-100000000000;

-- Upit 4: Poklon pristup tečaju (Trial) koji se sam briše nakon 7 dana (604800 sekundi)
INSERT INTO upis (student_id, tecaj_id, datum_upisa, napredak, status) VALUES (11111111-1111-1111-1111-111111111111, 20000000-2000-2000-2000-200000000000, toTimestamp(now()), 0, 'probni_pristup') USING TTL 604800;


-- ====================================================================
-- INDEKS KAO ZAMJENA ZA POGLED I AGREGACIJE
-- ====================================================================

-- Traži se Materialized View za brzu pretragu po kategoriji. 
-- Budući da su pogledi isključeni u Cassandri 5, radimo indeks nad stupcem kategorija!
CREATE INDEX idx_kategorija_tecaja ON tecaj (kategorija);

-- Brza pretraga tečajeva iz kategorije 'Dizajn' (radi bez ALLOW FILTERING zahvaljujući indeksu)
SELECT * FROM tecaj WHERE kategorija = 'Dizajn';

-- Agregacija A: Ukupan broj upisanih studenata na tečaj 'Uvod u Python'
SELECT COUNT(*) AS broj_upisanih FROM upis WHERE tecaj_id = 10000000-1000-1000-1000-100000000000 ALLOW FILTERING;

-- Agregacija B: Prosječan napredak Studenta 111... kroz sve njegove tečajeve
SELECT AVG(napredak) AS prosjecan_napredak FROM upis WHERE student_id = 11111111-1111-1111-1111-111111111111;
