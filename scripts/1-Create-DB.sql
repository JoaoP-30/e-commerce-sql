-- Descrição: Desativa temporariamente a verificação de índices únicos e chaves estrangeiras.
-- Isso é uma boa prática ao rodar scripts de criação em lote para evitar conflitos de ordem de execução.
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Descrição: Cria o schema (banco de dados) 'mydb' caso ele ainda não exista no servidor, utilizando a codificação padrão UTF-8.
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
-- Descrição: Define 'mydb' como o banco de dados ativo para a execução dos comandos seguintes.
USE `mydb` ;

-- -----------------------------------------------------
-- Tabela `mydb`.`Usuario`
-- -----------------------------------------------------
-- Descrição: Cria a tabela base 'Usuario' para armazenar os dados comuns de clientes e vendedores.
-- Restrições Aplicadas: 
-- 1. PRIMARY KEY: 'ID_usuario' identifica de forma única cada usuário e possui incremento automático.
-- 2. UNIQUE: O campo 'email' impede que dois usuários se cadastrem com o mesmo endereço eletrônico.
-- 3. DEFAULT: O campo 'data_cadastro' preenche automaticamente a data atual do sistema caso nenhum valor seja enviado.
-- 4. CHECK: Garante que o tipo de usuário seja restrito apenas a 'C' (Cliente) ou 'V' (Vendedor).
CREATE TABLE IF NOT EXISTS `mydb`.`Usuario` (
  `ID_usuario` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(30) NOT NULL,
  `email` VARCHAR(30) NOT NULL,
  `senha` VARCHAR(15) NOT NULL,
  `data_cadastro` DATE NOT NULL DEFAULT (CURRENT_DATE),
  `tipo_usuario` CHAR(1) NOT NULL CHECK (tipo_usuario IN ('C', 'V')),
  `logradouro` VARCHAR(30) NOT NULL,
  `numero` INT(5) NOT NULL,
  `complemento` VARCHAR(30) NULL,
  `bairro` VARCHAR(20) NOT NULL,
  `cidade` VARCHAR(30) NOT NULL,
  `estado` CHAR(2) NOT NULL,
  `cep` CHAR(8) NOT NULL,
  PRIMARY KEY (`ID_usuario`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC) VISIBLE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Telefone`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Telefone' para mapear a propriedade multivalorada de telefones dos usuários.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY Composta: A união de 'ID_usuario' e 'numero' garante que um usuário possa ter múltiplos telefones únicos.
-- 2. FOREIGN KEY: Conecta a tabela à entidade 'Usuario'.
-- 3. ON DELETE/UPDATE CASCADE: Se um usuário for excluído ou atualizado na tabela pai, seus respectivos telefones associados são removidos ou atualizados automaticamente.
CREATE TABLE IF NOT EXISTS `mydb`.`Telefone` (
  `ID_usuario` INT NOT NULL,
  `numero` CHAR(11) NOT NULL,
  PRIMARY KEY (`ID_usuario`, `numero`),
  CONSTRAINT `fk_Telefone_Usuario`
    FOREIGN KEY (`ID_usuario`)
    REFERENCES `mydb`.`Usuario` (`ID_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Vendedor`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Vendedor', que representa uma especialização da entidade 'Usuario'.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY: 'ID_vendedor' herda diretamente o identificador gerado na tabela Usuario.
-- 2. UNIQUE: O 'cnpj' é definido como único, impedindo empresas duplicadas.
-- 3. DEFAULT e CHECK: A reputação inicia em 0.00 por padrão e é blindada para aceitar apenas valores de 0 a 5.
-- 4. FOREIGN KEY: Vincula a integridade do vendedor ao registro pai em 'Usuario' com efeito CASCADE.
CREATE TABLE IF NOT EXISTS `mydb`.`Vendedor` (
  `ID_vendedor` INT NOT NULL,
  `cnpj` CHAR(14) NOT NULL,
  `razao_social` VARCHAR(30) NOT NULL,
  `nome_fantasia` VARCHAR(30) NOT NULL,
  `reputacao` DECIMAL(3,2) NOT NULL DEFAULT 0.00 CHECK (reputacao >= 0.00 AND reputacao <= 5.00),
  PRIMARY KEY (`ID_vendedor`),
  UNIQUE INDEX `cnpj_UNIQUE` (`cnpj` ASC) VISIBLE,
  CONSTRAINT `fk_Vendedor_Usuario`
    FOREIGN KEY (`ID_vendedor`)
    REFERENCES `mydb`.`Usuario` (`ID_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Cliente`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Cliente', que representa a outra especialização da entidade 'Usuario'.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY: O 'ID_cliente' está diretamente amarrado à chave primária correspondente do usuário.
-- 2. UNIQUE: O campo 'cpf' impede o cadastro de clientes com documentos idênticos.
-- 3. FOREIGN KEY: Cria o vínculo de integridade referencial de herança com a tabela 'Usuario'.
CREATE TABLE IF NOT EXISTS `mydb`.`Cliente` (
  `ID_cliente` INT NOT NULL,
  `cpf` CHAR(11) NOT NULL,
  PRIMARY KEY (`ID_cliente`),
  UNIQUE INDEX `cpf_UNIQUE` (`cpf` ASC) VISIBLE,
  CONSTRAINT `fk_Cliente_Usuario`
    FOREIGN KEY (`ID_cliente`)
    REFERENCES `mydb`.`Usuario` (`ID_usuario`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Avalia`
-- -----------------------------------------------------
-- Descrição: Cria a tabela associativa 'Avalia', que quebra a relação de Muitos para Muitos (N:M) entre Clientes e Vendedores.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY Composta: Composta por 'ID_Vendedor' e 'ID_Cliente', garantindo que um cliente possa avaliar um vendedor específico apenas uma vez.
-- 2. CHECK: A nota de avaliação é obrigatoriamente forçada a ficar na faixa de 1 a 5.
-- 3. FOREIGN KEYS: Conecta os envolvidos com integridade referencial em cascata (CASCADE) para deleção e atualização.
CREATE TABLE IF NOT EXISTS `mydb`.`Avalia` (
  `ID_Vendedor` INT NOT NULL,
  `ID_Cliente` INT NOT NULL,
  `comentario` VARCHAR(200) NULL,
  `avaliacao` INT(1) NOT NULL CHECK (avaliacao >= 1 AND avaliacao <= 5),
  PRIMARY KEY (`ID_Vendedor`, `ID_Cliente`),
  INDEX `fk_Vendedor_has_Cliente_Cliente1_idx` (`ID_Cliente` ASC) VISIBLE,
  INDEX `fk_Vendedor_has_Cliente_Vendedor1_idx` (`ID_Vendedor` ASC) VISIBLE,
  CONSTRAINT `fk_Avalia_Vendedor`
    FOREIGN KEY (`ID_Vendedor`)
    REFERENCES `mydb`.`Vendedor` (`ID_vendedor`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Avalia_Cliente`
    FOREIGN KEY (`ID_Cliente`)
    REFERENCES `mydb`.`Cliente` (`ID_cliente`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Produto`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Produto' contendo as especificações das mercadorias cadastradas.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY: 'ID_produto' mapeia de forma exclusiva o item.
-- 2. DEFAULT e CHECK: O estoque assume 0 por padrão e impede valores negativos de inventário através do CHECK.
-- 3. FOREIGN KEY com RESTRICT: Conecta o produto ao seu vendedor dono. A cláusula RESTRICT impede que um vendedor seja excluído do sistema se ele possuir produtos ativos cadastrados.
CREATE TABLE IF NOT EXISTS `mydb`.`Produto` (
  `ID_produto` INT(6) NOT NULL AUTO_INCREMENT,
  `nome_produto` VARCHAR(30) NOT NULL,
  `descricao` VARCHAR(200) NOT NULL,
  `marca` VARCHAR(30) NOT NULL,
  `preco_unitario` DECIMAL(8,2) NOT NULL,
  `quant_estoque` INT(5) NOT NULL CHECK (quant_estoque >= 0) DEFAULT 0,
  `vendedor_id` INT NOT NULL,
  PRIMARY KEY (`ID_produto`),
  INDEX `vendedor_id_idx` (`vendedor_id` ASC) VISIBLE,
  CONSTRAINT `vendedor_id`
    FOREIGN KEY (`vendedor_id`)
    REFERENCES `mydb`.`Vendedor` (`ID_vendedor`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Categoria`
-- -----------------------------------------------------
-- Descrição: Cria a tabela de 'Categoria' para fins de catalogação e organização de produtos.
CREATE TABLE IF NOT EXISTS `mydb`.`Categoria` (
  `ID_categoria` INT(6) NOT NULL,
  `nome_categoria` VARCHAR(50) NOT NULL,
  `descricao` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`ID_categoria`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`ProdutoCategoria`
-- -----------------------------------------------------
-- Descrição: Tabela associativa que resolve o relacionamento N:M entre Produto e Categoria.
-- Restrições Aplicadas: Chave primária composta e chaves estrangeiras com comportamento em cascata (CASCADE).
CREATE TABLE IF NOT EXISTS `mydb`.`ProdutoCategoria` (
  `ID_categoria` INT(6) NOT NULL,
  `ID_produto` INT(6) NOT NULL,
  PRIMARY KEY (`ID_categoria`, `ID_produto`),
  INDEX `fk_Categoria_has_Produto_Produto1_idx` (`ID_produto` ASC) VISIBLE,
  INDEX `fk_Categoria_has_Produto_Categoria1_idx` (`ID_categoria` ASC) VISIBLE,
  CONSTRAINT `fk_ProdutoCategoria_Categoria`
    FOREIGN KEY (`ID_categoria`)
    REFERENCES `mydb`.`Categoria` (`ID_categoria`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ProdutoCategoria_Produto`
    FOREIGN KEY (`ID_produto`)
    REFERENCES `mydb`.`Produto` (`ID_produto`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Pedido`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Pedido' para o cabeçalho das compras efetuadas.
-- Restrições Aplicadas:
-- 1. DEFAULT: O valor total do pedido inicia zerado (0.00).
-- 2. FOREIGN KEY com RESTRICT: Associa o pedido ao seu respectivo 'Cliente', impedindo a remoção de um cliente histórico que possua compras no banco.
CREATE TABLE IF NOT EXISTS `mydb`.`Pedido` (
  `ID_pedido` INT(6) NOT NULL,
  `data_hora` DATETIME NOT NULL,
  `status` VARCHAR(20) NOT NULL,
  `valor_total` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `id_cliente` INT NOT NULL,
  PRIMARY KEY (`ID_pedido`),
  INDEX `id_cliente_idx` (`id_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_Pedido_Cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `mydb`.`Cliente` (`ID_cliente`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`ItemPedido`
-- -----------------------------------------------------
-- Descrição: Cria a tabela de 'ItemPedido', entidade fraca que discrimina as linhas de produtos contidas em um pedido.
-- Restrições Aplicadas:
-- 1. PRIMARY KEY Composta: Junção de 'ID_pedido' e 'num_item'.
-- 2. FOREIGN KEYS: O pedido possui deleção CASCADE (se o pedido for apagado, somem suas linhas de itens). A relação com o 'Produto' possui integridade RESTRICT (impede a exclusão de um produto que já foi vendido em algum item de pedido ativo).
CREATE TABLE IF NOT EXISTS `mydb`.`ItemPedido` (
  `ID_pedido` INT(6) NOT NULL,
  `num_item` INT(4) NOT NULL,
  `quantidade` INT(4) NOT NULL,
  `preco_venda` DECIMAL(8,2) NOT NULL,
  `sub_total` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `id_produto` INT NOT NULL,
  PRIMARY KEY (`ID_pedido`, `num_item`),
  INDEX `id_produto_idx` (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_ItemPedido_Pedido`
    FOREIGN KEY (`ID_pedido`)
    REFERENCES `mydb`.`Pedido` (`ID_pedido`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_ItemPedido_Produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `mydb`.`Produto` (`ID_produto`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Pagamento`
-- -----------------------------------------------------
-- Descrição: Cria a tabela de 'Pagamento' para controlar as transações financeiras.
-- Restrições Aplicadas:
-- 1. CHECK: Mapeia de forma estrita o domínio do status do pagamento apenas para 'P' (Pendente), 'A' (Aprovado) ou 'R' (Recusado).
-- 2. FOREIGN KEY: Ligação 1:1 implícita com a tabela Pedido via CASCADE.
CREATE TABLE IF NOT EXISTS `mydb`.`Pagamento` (
  `ID_pedido` INT(6) NOT NULL,
  `status` CHAR(1) NOT NULL CHECK (status IN ('P', 'A', 'R')),
  `forma_pagamento` VARCHAR(10) NOT NULL,
  `data_pagamento` DATE NOT NULL,
  PRIMARY KEY (`ID_pedido`),
  CONSTRAINT `fk_Pagamento_Pedido`
    FOREIGN KEY (`ID_pedido`)
    REFERENCES `mydb`.`Pedido` (`ID_pedido`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Tabela `mydb`.`Entrega`
-- -----------------------------------------------------
-- Descrição: Cria a tabela 'Entrega' para gerenciar os despachos logísticos.
-- Restrições Aplicadas: 
-- 1. CHECK: Valida o preenchimento correto dos status para 'Pendente', 'Entregue' ou 'Cancelada'.
-- 2. FOREIGN KEY: Relaciona a entrega a um 'Pedido' ativo em modo RESTRICT.
CREATE TABLE IF NOT EXISTS `mydb`.`Entrega` (
  `ID_entrega` INT(6) NOT NULL,
  `data_previsao` DATE NOT NULL,
  `data_entrega` DATE NULL,
  `status` VARCHAR(20) NOT NULL CHECK (status IN ('Pendente', 'Entregue', 'Cancelada')),
  `id_pedido` INT(6) NOT NULL,
  PRIMARY KEY (`ID_entrega`),
  INDEX `id_pedido_idx` (`id_pedido` ASC) VISIBLE,
  CONSTRAINT `fk_Entrega_Pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `mydb`.`Pedido` (`ID_pedido`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;

-- Descrição: Restaura as configurações normais do servidor MySQL após as criações.
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


-- Descrição: 1º Exemplo de ALTER TABLE. Adiciona uma nova coluna física chamada 'peso' do tipo decimal na tabela 'Produto', permitindo calcular fretes no futuro.
ALTER TABLE Produto
ADD COLUMN peso DECIMAL(5,2);

-- Descrição: 2º Exemplo de ALTER TABLE. Modifica o tipo de dado do atributo 'nome_produto' na tabela 'Produto', aumentando seu espaço limite de armazenamento de 30 para 50 caracteres.
ALTER TABLE Produto
MODIFY COLUMN nome_produto VARCHAR(50);

-- Descrição: 3º Exemplo de ALTER TABLE. Acrescenta uma restrição do tipo CHECK (chk_valor_total) na tabela 'Pedido', assegurando que o sistema jamais aceite um valor total de pedido menor que zero.
ALTER TABLE Pedido
ADD CONSTRAINT chk_valor_total
CHECK (valor_total >= 0);

-- Descrição: Exemplo de Criação de Tabela Extra. Cria a tabela 'TabelaTeste' temporariamente para servir de base ao teste de exclusão exigido pela etapa.
CREATE TABLE TabelaTeste (
    id_teste INT PRIMARY KEY,
    descricao VARCHAR(50)
);

-- Descrição: Exemplo de DROP TABLE. Remove permanentemente do banco de dados a tabela 'TabelaTeste' que foi criada apenas para testes estruturais, eliminando seus metadados.
DROP TABLE TabelaTeste;