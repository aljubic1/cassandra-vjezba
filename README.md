# Vježba — Apache Cassandra

Ovaj projekt sadrži rješenja za vježbu iz NoSQL baze podataka Apache Cassandra. Sustav je podignut lokalno unutar Docker okruženja.

## Struktura projekta
* **`queries.cql`** — Skripta koja sadrži sve upite rađene kroz vježbu (kreiranje tablica, upisivanje podataka, pretraživanje, brisanje i završni zadatak).
* **`ODGOVORI.md`** — Datoteka s teorijskim odgovorima na pitanja iz vježbe i objašnjenjem završnog rada.
* **`screenshots/`** — Mapa u kojoj se nalaze slike ekrana (dokazi) da su svi upiti uspješno izvršeni u terminalu.
* **`docker-compose.yml`** — Konfiguracijska datoteka za pokretanje Cassandre kroz Docker.

## Kako pokrenuti projekt?
1. Pokrenite Docker Desktop na računalu.
2. Otvorite terminal u mapi projekta i pokrenite bazu naredbom:
   docker compose up -d
3. Pričekajte oko pola minute da se baza pokrene, a zatim uđite u konzolu za pisanje upita (cqlsh) pomoću naredbe:
docker exec -it cassandra-vjezba-cassandra-1 cqlsh
Unutar konzole možete kopirati i testirati sve naredbe iz datoteke queries.cql.
4. Spremi datoteku s **Ctrl + S**.

 