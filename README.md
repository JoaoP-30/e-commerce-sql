# 🛒 E-Commerce Database Simulation
Este repositório apresenta a modelagem e implementação de um banco de dados relacional robusto para uma plataforma de e-commerce inspirada no Mercado Livre. O projeto cobre todo o fluxo: cadastro de usuários, gerenciamento de produtos, pedidos, estoque, pagamentos, entregas e avaliações.

## 📌 Estrutura do Projeto
O projeto foi organizado em scripts SQL sequenciais, garantindo modularidade e fácil manutenção:

1-Create-DB.sql → Criação do Schema (mydb), tabelas, chaves primárias/estrangeiras e restrições (CHECK, UNIQUE, DEFAULT). Inclui exemplos com ALTER TABLE.

2-Populate-DB.sql → Inserção de dados iniciais para testes, simulando cenários reais de clientes, vendedores e pedidos.

3-Triggers.sql → Regras de negócio automatizadas (ex: atualização de reputação de vendedores, validação de tipos de usuários).

4-Procedures.sql → Stored Procedures para consultas avançadas (ex: gasto total por cliente, classificação Ouro/Prata/Bronze).

5-Views.sql → Views para relatórios prontos (ex: pedidos detalhados, entregas pendentes, ranking de produtos).

## 🗺️ Modelagem do Banco de Dados
O banco segue boas práticas de normalização e está documentado com diagramas:

* **Modelo Entidade-Relacionamento (MER):**
   ![Diagrama ER](https://github.com/JoaoP-30/e-commerce-sql/blob/main/images/DiagramaER.jpg)

* **Diagrama Relacional (Lógico):**
     ![Diagrama Relacional](https://github.com/JoaoP-30/e-commerce-sql/blob/main/images/DiagramaRelacional.png)


Principais Entidades:
Usuários: Cadastro unificado com dados pessoais e endereço.

Clientes: Identificados por CPF, realizam pedidos e avaliações.

Vendedores: Identificados por CNPJ, gerenciam produtos e reputação.

Produtos: Nome, preço, descrição, marca, categoria, peso e estoque.

Pedidos: Itens vinculados, pagamento automático e entrega com rastreamento.

## 🚀 Como Executar
Para rodar o projeto em MySQL:

### 1. Crie a estrutura
mysql -u seu_usuario -p < 1-Create-DB.sql

### 2. Popule os dados
mysql -u seu_usuario -p < 2-Populate-DB.sql

### 3. Instale os Triggers
mysql -u seu_usuario -p < 3-Triggers.sql

### 4. Carregue as Procedures
mysql -u seu_usuario -p < 4-Procedures.sql

### 5. Crie as Views
mysql -u seu_usuario -p < 5-Views.sql

## 💻 Forma Alternativa: MySQL Workbench
Se preferir uma interface gráfica em vez do terminal, você pode executar todos os scripts diretamente pelo MySQL Workbench:

Abra o MySQL Workbench e conecte-se ao seu servidor.

Crie uma nova aba de query (File > New Query Tab).

Copie e execute cada script na ordem numérica (1-Create-DB.sql até 5-Views.sql).

O Workbench permite acompanhar a execução passo a passo, visualizar tabelas, triggers, procedures e views de forma interativa.

## 🛠️ Tecnologias
SGBD: MySQL

Linguagem: SQL (DDL, DML, DCL)

Ferramentas: MySQL Workbench
