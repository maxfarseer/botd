alias Botd.People

attrs = %{
  name: "Ghost Petrovich",
  nickname: "Kasper",
  birth_date: "1900-01-01",
  death_date: "2000-01-01",
  place: "New York",
  cause_of_death: "Алкоголь",
  description: "Хорошее было приведение."
}

result = People.create_person(attrs)
IO.inspect(result)
