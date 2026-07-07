
-- A view DetalhesPedidos é criada para exibir os detalhes dos pedidos, 
-- incluindo o ID do pedido, o nome do cliente, o nome do vendedor, os 
-- produtos incluídos no pedido e o status da entrega. Ela utiliza várias 
-- junções para combinar informações de diferentes tabelas relacionadas aos pedidos

CREATE VIEW DetalhesPedidos AS
SELECT 
    p.ID_pedido,
    u.nome AS nome_cliente,
    v.nome_fantasia AS nome_vendedor,
    e.status AS status_entrega,
    GROUP_CONCAT(pr.nome_produto SEPARATOR ', ') as produtos 

FROM Pedido p
JOIN Usuario u ON p.id_cliente = u.ID_usuario
JOIN ItemPedido ip ON p.ID_pedido = ip.ID_pedido
JOIN Produto pr ON ip.id_produto = pr.ID_produto
JOIN Vendedor v ON pr.vendedor_id = v.ID_vendedor
JOIN Entrega e ON p.ID_pedido = e.id_pedido

GROUP BY p.ID_pedido, u.nome, v.nome_fantasia, e.status;

-- A view EntregasPendentes é criada para exibir os pedidos que ainda não foram entregues, 
-- mostrando o ID do pedido, o nome do cliente,e a data prevista para entrega.


CREATE VIEW EntregasPendentes AS
SELECT 
    p.ID_pedido,
    u.nome AS nome_cliente,
    e.data_previsao AS data_previsao_entrega
FROM Pedido p
JOIN Usuario u ON p.ID_cliente = u.ID_usuario
JOIN Entrega e ON p.ID_pedido = e.id_pedido
WHERE e.status = 'Pendente';

-- A view ProdutosMaisVendidos é criada para exibir os 10 produtos mais vendidos, 
-- mostrando o nome do produto e a quantidade total vendida.

CREATE VIEW ProdutosMaisVendidos AS
SELECT 
    pr.nome_produto,
    SUM(ip.quantidade) AS quantidade_vendida
FROM ItemPedido ip
JOIN Produto pr ON ip.id_produto = pr.ID_produto
GROUP BY pr.nome_produto
ORDER BY quantidade_vendida DESC
LIMIT 10;

