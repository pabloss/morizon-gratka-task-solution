# Używamy oficjalnego obrazu Elixira (wersja oparta na Debianie jest bardziej kompletna niż Alpine dla środowisk dev)
FROM elixir:1.16

# Instalujemy narzędzia systemowe:
# - inotify-tools: kluczowe dla Phoenixa do wykrywania zmian w plikach (live reload) wewnątrz kontenera
# - build-essential: potrzebne do kompilacji niektórych zależności C/C++
RUN apt-get update && \
    apt-get install -y inotify-tools build-essential && \
    rm -rf /var/lib/apt/lists/*

# Ustawiamy katalog roboczy
WORKDIR /app

# Instalujemy Hex (menedżer pakietów) i Rebar (narzędzie budowania dla Erlanga)
RUN mix local.hex --force && \
    mix local.rebar --force

# Instalujemy generator projektów Phoenix (to spełnia Twoją prośbę o "zainstalowanie frameworka")
# Pozwoli to używać komendy `mix phx.new`
RUN mix archive.install hex phx_new --force

# Kopiujemy pliki zależności (jeśli istnieją), aby wykorzystać cache Dockera
# Jeśli katalog jest pusty, ten krok może rzucić błąd przy buildzie,
# dlatego w sekcji "Jak wystartować" wyjaśniam, co zrobić.
COPY mix.exs mix.lock ./
#COPY phoenix-api/mix.exs mix.lock ./

# Instalujemy zależności i kompilujemy je
# Używamy konstrukcji "|| true", aby build nie wywalił się, jeśli nie ma jeszcze pliku mix.exs (np. pusty katalog)
RUN if [ -f mix.exs ]; then mix deps.get; fi

# Kopiujemy resztę kodu aplikacji
COPY . .

# Wystawiamy port, na którym domyślnie działa Phoenix
EXPOSE 4000

# Domyślna komenda startowa servera
CMD ["mix", "phx.server"]