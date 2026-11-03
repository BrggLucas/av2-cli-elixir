defmodule AgendaCli.Store do
  def load do
    case File.read("contacts.json") do
      {:ok, json} ->
        json
        |> Jason.decode!()
        |> Enum.map(fn contact ->
          %{
            id: contact["id"],
            name: contact["name"],
            company: contact["company"],
            phone: contact["phone"],
            email: contact["email"]
          }
        end)
      {:error, :enoent} -> []
    end
  end

  def save(contacts) do
    contacts
    |> Jason.encode!(pretty: true)
    |> then(&File.write!("contacts.json", &1))
  end
end
