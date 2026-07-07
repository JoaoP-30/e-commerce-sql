-- Este conjunto de triggers garante que a reputação do vendedor seja sempre atualizada corretamente após qualquer operação de 
-- inserção, atualização ou exclusão de avaliações na tabela Avalia.

DELIMITER $$
CREATE TRIGGER AtualizaReputacao
AFTER INSERT ON Avalia
FOR EACH ROW
BEGIN
    DECLARE nova_reputacao FLOAT;
    SELECT AVG(avaliacao) INTO nova_reputacao
    FROM Avalia
    WHERE ID_Vendedor = NEW.ID_Vendedor;
    UPDATE Vendedor
    SET reputacao = nova_reputacao
    WHERE ID_vendedor = NEW.ID_Vendedor;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER AtualizaReputacaoUpdate
AFTER UPDATE ON Avalia
FOR EACH ROW
BEGIN
    DECLARE nova_reputacao FLOAT;
    SELECT AVG(avaliacao) INTO nova_reputacao
    FROM Avalia
    WHERE ID_Vendedor = NEW.ID_Vendedor;
    UPDATE Vendedor
    SET reputacao = nova_reputacao
    WHERE ID_vendedor = NEW.ID_Vendedor;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER AtualizaReputacaoDelete
AFTER DELETE ON Avalia
FOR EACH ROW
BEGIN
    DECLARE nova_reputacao FLOAT;
    SELECT AVG(avaliacao) INTO nova_reputacao
    FROM Avalia
    WHERE ID_Vendedor = OLD.ID_Vendedor;
    UPDATE Vendedor
    SET reputacao = nova_reputacao
    WHERE ID_vendedor = OLD.ID_Vendedor;
END$$
DELIMITER ;


--- Esse conjunto de triggers garante que o status da entrega seja sempre atualizado corretamente
--- após qualquer operação de atualização na tabela Entrega.

DELIMITER $$
CREATE TRIGGER AtualizaStatusEntrega
AFTER UPDATE ON Entrega
FOR EACH ROW
BEGIN
    IF NEW.data_entrega IS NOT NULL THEN
        UPDATE Entrega
        SET status = 'Entregue'
        WHERE ID_entrega = NEW.ID_entrega;
    END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER VerificaDataEntrega
BEFORE UPDATE ON Entrega
FOR EACH ROW
BEGIN
    IF NEW.data_entrega IS NOT NULL AND NEW.data_entrega > NEW.data_previsao THEN
        UPDATE Entrega
        SET status = 'Pendente'
        WHERE ID_entrega = NEW.ID_entrega;
    END IF;
END$$

-- Este conjunto de triggers garante que o sub_total do item do pedido seja sempre atualizado corretamente
-- após qualquer operação de inserção ou atualização de itens de pedido na tabela ItemPedido.

DELIMITER $$
CREATE TRIGGER before_itempedido_insert
BEFORE INSERT ON ItemPedido
FOR EACH ROW
BEGIN
    SET NEW.sub_total = NEW.quantidade * NEW.preco_venda;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER before_itempedido_update
BEFORE UPDATE ON ItemPedido
FOR EACH ROW
BEGIN
    IF NEW.quantidade <> OLD.quantidade OR NEW.preco_venda <> OLD.preco_venda THEN
        SET NEW.sub_total = NEW.quantidade * NEW.preco_venda;
    END IF;
END$$
DELIMITER ;

--- Este conjunto de triggers garante que o estoque do produto seja sempre atualizado corretamente
--- após qualquer operação de inserção, atualização ou exclusão de itens de pedido na tabela ItemPedido.

DELIMITER $$
CREATE TRIGGER after_itempedido_insert
AFTER INSERT ON ItemPedido
FOR EACH ROW
BEGIN
    UPDATE Produto
    SET estoque = estoque - NEW.quantidade
    WHERE ID_produto = NEW.id_produto;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_itempedido_update
AFTER UPDATE ON ItemPedido
FOR EACH ROW
BEGIN
    IF NEW.quantidade <> OLD.quantidade THEN
        UPDATE Produto
        SET estoque = estoque - (NEW.quantidade - OLD.quantidade)
        WHERE ID_produto = NEW.id_produto;
    END IF;
END$$
DELIMITER ; 

DELIMITER $$
CREATE TRIGGER  
AFTER DELETE ON ItemPedido
FOR EACH ROW
BEGIN
    UPDATE Produto
    SET estoque = estoque + OLD.quantidade
    WHERE ID_produto = OLD.id_produto;
END$$
DELIMITER ; 

--- Este conjunto de triggers garante que o total do pedido seja sempre atualizado corretamente
--- após qualquer operação de inserção, atualização ou exclusão de itens de pedido na tabela ItemPedido.

DELIMITER $$

CREATE TRIGGER after_itempedido_insert_update
AFTER INSERT ON ItemPedido
FOR EACH ROW
BEGIN
    UPDATE Pedido
    SET total = total + NEW.sub_total
    WHERE ID_pedido = NEW.ID_pedido;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_itempedido_update_update
AFTER UPDATE ON ItemPedido
FOR EACH ROW
BEGIN
    IF NEW.sub_total <> OLD.sub_total THEN
        UPDATE Pedido
        SET total = total + (NEW.sub_total - OLD.sub_total)
        WHERE ID_pedido = NEW.ID_pedido;
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_itempedido_delete
AFTER DELETE ON ItemPedido
FOR EACH ROW
BEGIN
    UPDATE Pedido
    SET total = total - OLD.sub_total
    WHERE ID_pedido = OLD.ID_pedido;
END$$
DELIMITER ; 


-- Este trigger garante que a data de cadastro não seja futura

DELIMITER $$
CREATE TRIGGER before_usuario_insert
BEFORE INSERT ON Usuario
FOR EACH ROW
BEGIN
    IF NEW.data_cadastro > CURDATE() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de cadastro não pode ser futura.';
    END IF;
END$$
DELIMITER ;



-- Esse trigger garante que o ID_vendedor inserido na tabela Vendedor exista na tabela Usuario e seja do tipo 'V' (Vendedor).

DELIMITER $$
CREATE TRIGGER before_vendedor_insert
BEFORE INSERT ON Vendedor
FOR EACH ROW
BEGIN
    DECLARE user_type CHAR(1);
    SELECT tipo_usuario INTO user_type FROM Usuario WHERE ID_usuario = NEW.ID_vendedor;
    IF user_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID_vendedor deve existir na tabela Usuario';
    ELSEIF user_type != 'V' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID_vendedor deve ser do tipo V (Vendedor)';
    END IF;
END$$
DELIMITER ;

-- Esse trigger garante que o ID_cliente inserido na tabela Cliente exista na tabela Usuario e seja do tipo 'C' (Cliente).

DELIMITER $$
CREATE TRIGGER before_cliente_insert
BEFORE INSERT ON Cliente
FOR EACH ROW
BEGIN
    DECLARE user_type CHAR(1);
    SELECT tipo_usuario INTO user_type FROM Usuario WHERE ID_usuario = NEW.ID_cliente;
    IF user_type IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID_cliente deve existir na tabela Usuario';
    ELSEIF user_type != 'C' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID_cliente deve ser do tipo C (Cliente)';
    END IF;
END$$
DELIMITER ;

