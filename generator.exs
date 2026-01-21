# Instalacja zależności
Mix.install([
  {:nimble_csv, "~> 1.2"}
])

# Definicja parsera
NimbleCSV.define(MyParser, separator: ",", escape: "\"")

defmodule UserGenerator do
  alias MyParser, as: CSV

  # Konfiguracja tabeli docelowej w Postgres
  @table_name "users"
  @output_file "users_seed.sql"

  def run do
    files = %{
      f_names: {"imiona_zenskie.csv", "IMIĘ_PIERWSZE", "LICZBA_WYSTĄPIEŃ"},
      m_names: {"imiona_meskie.csv", "IMIĘ_PIERWSZE", "LICZBA_WYSTĄPIEŃ"},
      f_surnames: {"nazwiska_zenskie.csv", "Nazwisko aktualne", "Liczba"},
      m_surnames: {"nazwiska_meskie.csv", "Nazwisko aktualne", "Liczba"}
    }

    IO.puts("1. Wczytywanie danych...")
    data = %{
      female_names: get_top_100(files.f_names),
      male_names: get_top_100(files.m_names),
      female_surnames: get_top_100(files.f_surnames),
      male_surnames: get_top_100(files.m_surnames)
    }

    IO.puts("2. Generowanie danych użytkowników...")
    users =
      1..100
      |> Enum.map(fn _ -> generate_random_user(data) end)

    IO.puts("3. Generowanie pliku SQL...")
    sql_content = generate_sql_insert(users)

    File.write!(@output_file, sql_content)
    IO.puts("Gotowe! Wygenerowano plik: #{@output_file}")
    IO.puts("Przykładowy fragment:")
    IO.puts(String.slice(sql_content, 0, 300) <> "...")
  end

  # --- Logika SQL ---

  defp generate_sql_insert(users) do
    # Nagłówek INSERT
    header = "INSERT INTO #{@table_name} (first_name, last_name, gender, birth_date) VALUES\n"

    # Mapowanie użytkowników na krotki SQL (values)
    values =
      users
      |> Enum.map(fn u ->
        # Formatowanie pojedynczego wiersza
        name = sql_escape(u.imie)
        surname = sql_escape(u.nazwisko)
        gender = sql_escape(u.plec)
        date = Date.to_string(u.data_urodzenia)

        "    ('#{name}', '#{surname}', '#{gender}', '#{date}')"
      end)
      |> Enum.join(",\n")

    # Złożenie całości zamykając średnikiem
    header <> values <> ";"
  end

  # Prosta funkcja escape'ująca apostrofy dla SQL (O'Connor -> O''Connor)
  defp sql_escape(str) do
    String.replace(str, "'", "''")
  end

  # --- Logika Pobierania Danych (bez zmian) ---

  defp get_top_100({path, name_header, count_header}) do
    stream = File.stream!(path)
    header = stream |> CSV.parse_stream(skip_headers: false) |> Enum.take(1) |> List.first()

    name_idx = find_index(header, name_header)
    count_idx = find_index(header, count_header)

    stream
    |> CSV.parse_stream(skip_headers: true)
    |> Stream.map(fn row ->
      name = Enum.at(row, name_idx)
      count = Enum.at(row, count_idx) |> String.trim() |> String.to_integer()
      {name, count}
    end)
    |> Enum.sort_by(fn {_name, count} -> count end, :desc)
    |> Enum.take(100)
    |> Enum.map(fn {name, _count} -> name end)
  end

  defp find_index(header_row, col_name) do
    case Enum.find_index(header_row, fn h -> String.trim(h) == col_name end) do
      nil -> raise "Nie znaleziono kolumny: #{col_name}"
      idx -> idx
    end
  end

  # --- Logika Generowania (bez zmian) ---

  defp generate_random_user(data) do
    gender = Enum.random([:female, :male])

    {first_name, last_name, gender_str} =
      case gender do
        :female -> {Enum.random(data.female_names), Enum.random(data.female_surnames), "Kobieta"}
        :male -> {Enum.random(data.male_names), Enum.random(data.male_surnames), "Mężczyzna"}
      end

    %{
      imie: first_name,
      nazwisko: last_name,
      plec: gender_str,
      data_urodzenia: generate_random_date()
    }
  end

  defp generate_random_date do
    start_date = ~D[1970-01-01]
    end_date = ~D[2024-12-31]
    days_diff = Date.diff(end_date, start_date)
    Date.add(start_date, Enum.random(0..days_diff))
  end
end

UserGenerator.run()