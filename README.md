# Tetris w LÖVE2D

## Opis
Klasyczna implementacja gry Tetris stworzona przy użyciu silnika LÖVE2D w języku Lua. Gra zawiera wszystkie podstawowe mechaniki Tetrisa wraz z dodatkowymi funkcjami zapisu i wczytywania stanu gry.

## Spełnione wymagania
- ✅ 3.0 Postawowa wersja dekstopowa z obsługą na klawiaturze - minimum 4 rodzaje klocków
- ✅ 3.5 Zapis i odczyt gier
- ✅ 4.0 Dodanie efektów dźwiękowych przy akcjach
- ✅ 4.5 Dodanie animacji przy zbijaniu klocków
- ❌ 5.0 Wersja na iOS lub Android z implementacją touch zamiast klawiatury

## Sterowanie
- **Strzałka w lewo**: Przesuń klocek w lewo
- **Strzałka w prawo**: Przesuń klocek w prawo
- **Strzałka w dół**: Przyspiesz opadanie klocka
- **Strzałka w górę**: Obróć klocek
- **S**: Zapisz grę
- **L**: Wczytaj grę

## Konfiguracja
Główne ustawienia gry znajdują się w pliku konfiguracyjnym `src/constants/config.lua`.

## Struktura projektu
- `main.lua` - Główny plik gry
- `src/`
  - `constants/` - Stałe i konfiguracja
  - `entities/` - Klasy reprezentujące obiekty gry
  - `states/` - Zarządzanie stanem gry
  - `systems/` - Systemy gry (renderer, manager)
  - `utils/` - Narzędzia pomocnicze

## Wymagania
- LÖVE2D (https://love2d.org/)
- Lua 5.1 lub nowszy

## Instalacja
1. Zainstaluj LÖVE2D ze strony oficjalnej
2. Sklonuj repozytorium
3. Uruchom grę komendą:
`love .`

## Mechanika gry
Gra implementuje standardowe zasady Tetrisa:
- Klocki opadają automatycznie
- Można je obracać i przesuwać
- Zapełnione linie są usuwane
- Gra kończy się, gdy klocki dotrą do górnej krawędzi planszy

## System punktacji
Punkty są przyznawane za:
- Usunięcie 1 linii: 100 punktów
- Usunięcie 2 linii naraz: 300 punktów  
- Usunięcie 3 linii naraz: 500 punktów
- Usunięcie 4 linii naraz (Tetris): 800 punktów
- Szybkie upuszczenie klocka: 1 punkt za każdy poziom spadania

## System zapisu
Gra posiada system zapisu stanu, który przechowuje:
- Aktualny stan planszy
- Pozycję i kształt bieżącego klocka
- Wynik gracza
- Kolory klocków
