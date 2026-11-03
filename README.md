# Agenda CLI em Elixir

Agenda de contatos em linha de comando desenvolvida com Mix, Jason e programação funcional.

## Requisitos

- Elixir 1.20 e Erlang/OTP compatível
- Mix e Hex

## Instalação e execução

No terminal, dentro da pasta do projeto:

```bash
mix deps.get
mix run -e "AgendaCli.main([])"
```

O arquivo `contacts.json` fica na pasta de execução. Se não existir, a agenda começa vazia.

## Comandos

```text
add --name Ana Lima --company Acme Ltda --phone 85912345678 --email ana@acme.com
list
show 123
edit 123 --phone 85999999999
edit 123 --name Ana Silva --company Nova Empresa
del 123
search --name ana
search --phone 85
search --email gmail
exit
```

Substitua `123` pelo ID gerado automaticamente pelo comando `add` e exibido por `list`. No `add`, informe os quatro campos; no `edit`, apenas os que deseja alterar. O `search` aceita uma flag por comando. Valores com espaços podem ser fornecidos sem aspas, como nos exemplos.

## Estrutura

- `lib/agenda_cli.ex`: entrada, leitura de comandos, parsing e loop recursivo.
- `lib/agenda_cli/contacts.ex`: operações puras de lista (`add`, `delete`, `search`, `edit`, `show`).
- `lib/agenda_cli/store.ex`: leitura e escrita do JSON.
- `test/agenda_cli_test.exs`: testes automatizados.

## Testes

```bash
mix test
```
