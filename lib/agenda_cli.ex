defmodule AgendaCli do
  alias AgendaCli.Contacts
  alias AgendaCli.Store

  def main(_args) do
    Store.load()
    |> loop()
  end

  defp loop(contacts) do
    command = IO.gets("agenda> ") |> parse_input()

    case command do
      :exit ->
        IO.puts("Encerrando agenda.")

      :list ->
        list_contacts(contacts)
        loop(contacts)

      {:show, id} ->
        case Contacts.show(contacts, id) do
          nil -> IO.puts("Contato não encontrado.")
          contact -> list_contacts([contact])
        end
        loop(contacts)

      {:add, args} ->
        case parse_flags(args) do
          {:ok, data} ->
            if Enum.all?([:name, :company, :phone, :email], &Map.has_key?(data, &1)) and
                 Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, data[:email]) and
                 Regex.match?(~r/^\d{10,11}$/, data[:phone]) do
              contact = Map.put(data, :id, System.system_time(:millisecond))
              updated = Contacts.add(contacts, contact)
              Store.save(updated)
              IO.puts("Contato adicionado!")
              loop(updated)
            else
              IO.puts("Informe nome, empresa, telefone e e-mail válido.")
              loop(contacts)
            end
          :error ->
            IO.puts("Comando inválido.")
            loop(contacts)
        end

      {:del, id} ->
        if Contacts.show(contacts, id) do
          updated = Contacts.delete(contacts, id)
          Store.save(updated)
          IO.puts("Contato removido!")
          loop(updated)
        else
          IO.puts("Contato não encontrado.")
          loop(contacts)
        end

      {:search, field, value} ->
        contacts
        |> Contacts.search(field, value)
        |> list_contacts()
        loop(contacts)

      {:edit, id, args} ->
        case {Contacts.show(contacts, id), parse_flags(args)} do
          {nil, _} ->
            IO.puts("Contato não encontrado.")
            loop(contacts)
          {_, {:ok, changes}} ->
            if (not Map.has_key?(changes, :email) or
                  Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, changes[:email])) and
                 (not Map.has_key?(changes, :phone) or
                  Regex.match?(~r/^\d{10,11}$/, changes[:phone])) do
              updated = Contacts.edit(contacts, id, changes)
              Store.save(updated)
              IO.puts("Contato atualizado!")
              loop(updated)
            else
              IO.puts("Telefone ou e-mail inválido.")
              loop(contacts)
            end
          _ ->
            IO.puts("Comando inválido.")
            loop(contacts)
        end

      :unknown ->
        IO.puts("Comando inválido.")
        loop(contacts)
    end
  end

  defp parse_input(nil), do: :exit
  defp parse_input(input), do: input |> String.trim() |> parse_command()

  defp parse_command("exit"), do: :exit
  defp parse_command("list"), do: :list
  defp parse_command("add " <> args), do: {:add, args}

  defp parse_command("show " <> id), do: parse_id(:show, id)
  defp parse_command("del " <> id), do: parse_id(:del, id)

  defp parse_command("edit " <> args) do
    case String.split(args, " ", parts: 2) do
      [id, flags] ->
        case Integer.parse(id) do
          {number, ""} -> {:edit, number, flags}
          _ -> :unknown
        end
      _ -> :unknown
    end
  end

  defp parse_command("search --name " <> value), do: parse_search(:name, value)
  defp parse_command("search --phone " <> value), do: parse_search(:phone, value)
  defp parse_command("search --email " <> value), do: parse_search(:email, value)
  defp parse_command(_), do: :unknown

  defp parse_id(command, id) do
    case Integer.parse(id) do
      {number, ""} -> {command, number}
      _ -> :unknown
    end
  end

  defp parse_search(field, value) do
    if String.trim(value) != "" and not Regex.match?(~r/\s+--/, value) do
      {:search, field, value}
    else
      :unknown
    end
  end

  defp parse_flags(args) do
    parts =
      Regex.split(~r/\s+--/, " " <> args, trim: true)
      |> Enum.map(fn part ->
        case String.split(part, " ", parts: 2) do
          ["name", value] -> {:name, String.trim(value)}
          ["company", value] -> {:company, String.trim(value)}
          ["phone", value] -> {:phone, String.trim(value)}
          ["email", value] -> {:email, String.trim(value)}
          _ -> :error
        end
      end)

    if parts == [] or Enum.any?(parts, fn
         :error -> true
         {_, ""} -> true
         _ -> false
       end) or length(parts) != length(Enum.uniq_by(parts, fn {key, _} -> key end)) do
      :error
    else
      {:ok, Map.new(parts)}
    end
  end

  defp list_contacts(contacts) do
    Enum.each(contacts, fn contact ->
      IO.puts("#{contact.id} | #{contact.name} | #{contact.company} | #{contact.phone} | #{contact.email}")
    end)
  end
end
