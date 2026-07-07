-- Este procedimento TotalPedidosCliente recebe o ID do cliente como 
-- parâmetro de entrada e retorna o número total de pedidos realizados 
-- por esse cliente, bem como o valor total gasto em todos os pedidos.

DELIMITER $$
CREATE PROCEDURE TotalPedidosCliente (IN p_ID_cliente INT) 
BEGIN 
    SELECT 
        COUNT(*) AS total_pedidos, 
        SUM(ip.quantidade * pr.preco_unitario) AS valor_total_gasto
    FROM Pedido p 
    JOIN ItemPedido ip ON p.ID_pedido = ip.ID_pedido 
    JOIN Produto pr ON ip.id_produto = pr.ID_produto 
    WHERE p.ID_cliente = p_ID_cliente; 
END$$ 
DELIMITER ;


-- Este procedimento ClassificarClientes classifica os clientes com base 
-- no valor total gasto em seus pedidos, atribuindo categorias de acordo 
-- com os seguintes critérios:

--  Clientes que gastaram 1000 ou mais são classificados como "Ouro"
--  Clientes que gastaram entre 500 e 999 são classificados como "Prata"
--  Clientes que gastaram menos de 500 são classificados como "Bronze"

DELIMITER $$ 
CREATE PROCEDURE ClassificarClientes() 
BEGIN 
    SELECT 
        c.ID_cliente, 
        u.nome, 
        SUM(ip.quantidade * pr.preco_unitario) AS valor_total_gasto, 
        CASE 
            WHEN SUM(ip.quantidade * pr.preco_unitario) >= 1000 THEN 'Ouro' 
            WHEN SUM(ip.quantidade * pr.preco_unitario) >= 500 THEN 'Prata'
            ELSE 'Bronze'
        END AS categoria
    FROM Cliente c 
    JOIN Usuario u ON c.ID_cliente = u.ID_usuario
    JOIN Pedido p ON c.ID_cliente = p.ID_cliente
    JOIN ItemPedido ip ON p.ID_pedido = ip.ID_pedido
    JOIN Produto pr ON ip.id_produto = pr.ID_produto
    GROUP BY c.ID_cliente, u.nome;
END $$
DELIMITER ; 

CALL ClassificarClientes();


-- Este procedimento MaiorPedidoIntervaloDatas recebe duas datas como parâmetros 
-- de entrada e retorna o valor do maior pedido realizado durante esse intervalo de datas. 

-- O procedimento utiliza as funções de data para filtrar os pedidos realizados entre 
-- as datas especificadas e a função MAX para obter o valor do maior pedido encontrado.

DELIMITER $$ 
CREATE PROCEDURE MaiorPedidoIntervaloDatas (IN p_data_inicio DATE, IN p_data_fim DATE, OUT p_maior_valor DECIMAL(10,2))
BEGIN 
    DECLARE data_hora_inicio DATETIME;
    DECLARE data_hora_fim DATETIME;
    SET data_hora_inicio = CONCAT(p_data_inicio, ' 00:00:00');
    SET data_hora_fim = CONCAT(p_data_fim, ' 23:59:59'); 

    SELECT 
        MAX(p.valor_total) INTO p_maior_valor 
    FROM Pedido p 
    
    WHERE p.data_hora BETWEEN data_hora_inicio AND data_hora_fim; 
END$$ 
DELIMITER ;

