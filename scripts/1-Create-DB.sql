SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

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

CREATE TABLE IF NOT EXISTS `mydb`.`Categoria` (
  `ID_categoria` INT(6) NOT NULL,
  `nome_categoria` VARCHAR(50) NOT NULL,
  `descricao` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`ID_categoria`))
ENGINE = InnoDB;

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

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

