defmodule AgendaCli.Contacts do
  def add(contacts, contact), do: contacts ++ [contact]

  def delete(contacts, id) do
    Enum.reject(contacts, fn contact -> contact.id == id end)
  end

  def search(contacts, field, value) do
    Enum.filter(contacts, fn contact ->
      contact
      |> Map.get(field)
      |> to_string()
      |> String.downcase()
      |> String.contains?(String.downcase(value))
    end)
  end

  def edit(contacts, id, changes) do
    changes = Map.delete(changes, :id)
    Enum.map(contacts, fn contact ->
      if contact.id == id, do: Map.merge(contact, changes), else: contact
    end)
  end

  def show(contacts, id), do: Enum.find(contacts, fn contact -> contact.id == id end)
end
