# 📱 Sistema de Agendamento de Salas (Flutter)

Aplicação mobile desenvolvida em **Flutter** utilizando **SQLite** como banco de dados local, com foco na implementação de regras de negócio diretamente no banco.

---

## 🚀 Funcionalidades

* Cadastro de salas
* Edição e exclusão de salas
* Cadastro de agendamentos
* Edição e exclusão de agendamentos
* Seleção de data e hora para agendamento
* Validação de conflitos de horários
* Registro automático de operações (INSERT, UPDATE, DELETE)

---

## 🧱 Tecnologias utilizadas

* Flutter
* Dart
* SQLite
* sqflite

---

## 🗄️ Banco de Dados

O banco de dados é criado localmente utilizando SQLite e possui as seguintes tabelas:

* `sala`
* `agendamento`
* `log_operacao`

---

## ⚙️ Regras implementadas no banco

Todas as validações são executadas diretamente no banco de dados:

* Nome da sala obrigatório
* Nome da sala único
* Não permite nomes vazios ou apenas espaços
* Data/hora final deve ser maior que a inicial
* Não permite sobreposição de agendamentos para a mesma sala
* Não permite exclusão de sala com agendamento futuro
* Registro automático de operações em log (INSERT, UPDATE, DELETE)

---

## 🔄 Triggers implementadas

* Log automático para operações nas tabelas `sala` e `agendamento`
* Validação de conflito de horários
* Bloqueio de exclusão de salas com agendamentos futuros

---

## 📌 Diferencial do projeto

Este projeto prioriza a **lógica de negócio no banco de dados**, utilizando triggers e constraints para garantir a integridade dos dados, conforme solicitado no desafio.

---

## 👨‍💻 Autor

Tiago Bauer De Matos

---

