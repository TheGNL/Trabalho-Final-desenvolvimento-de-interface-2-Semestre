-- ================================================================================
-- PROJETO FINAL - BANCO DE DADOS II
-- Sistema de E-commerce (Eletrônicos e Roupas)
-- PostgreSQL 12+
-- ================================================================================

-- Limpar ambiente
DROP SCHEMA IF EXISTS loja CASCADE;
DROP SCHEMA IF EXISTS analitico CASCADE;

-- Criação do Schema OLTP
CREATE SCHEMA loja;
SET search_path TO loja, public;

-- ================================================================================
-- TABELAS DO MODELO TRANSACIONAL (OLTP) - 3ª FORMA NORMAL
-- ================================================================================

CREATE TABLE loja.cliente (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(15),
    data_nascimento DATE,
    logradouro VARCHAR(150),
    numero VARCHAR(10),
    complemento VARCHAR(50),
    bairro VARCHAR(50),
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(9),
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE,
    CONSTRAINT check_cpf_formato CHECK (cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$'),
    CONSTRAINT check_email_formato CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT check_estado_valido CHECK (LENGTH(estado) = 2)
);

CREATE TABLE loja.categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE loja.produto (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INTEGER NOT NULL,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco NUMERIC(10, 2) NOT NULL,
    peso_kg NUMERIC(8, 3),
    marca VARCHAR(50),
    modelo VARCHAR(50),
    cor VARCHAR(30),
    tamanho VARCHAR(10),
    ativo BOOLEAN DEFAULT TRUE,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) 
        REFERENCES loja.categoria(id_categoria) ON DELETE RESTRICT,
    CONSTRAINT check_preco_positivo CHECK (preco > 0),
    CONSTRAINT check_peso_positivo CHECK (peso_kg IS NULL OR peso_kg > 0)
);

CREATE TABLE loja.estoque (
    id_estoque SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL UNIQUE,
    quantidade INTEGER NOT NULL DEFAULT 0,
    quantidade_minima INTEGER DEFAULT 10,
    localizacao VARCHAR(50),
    ultima_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_estoque_produto FOREIGN KEY (id_produto) 
        REFERENCES loja.produto(id_produto) ON DELETE CASCADE,
    CONSTRAINT check_quantidade_nao_negativa CHECK (quantidade >= 0),
    CONSTRAINT check_qtd_minima_positiva CHECK (quantidade_minima >= 0)
);

CREATE TABLE loja.pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'PENDENTE' NOT NULL,
    valor_total NUMERIC(12, 2) DEFAULT 0,
    forma_pagamento VARCHAR(30),
    data_entrega DATE,
    observacoes TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) 
        REFERENCES loja.cliente(id_cliente) ON DELETE RESTRICT,
    CONSTRAINT check_status_valido CHECK (status IN ('PENDENTE', 'PROCESSANDO', 'ENVIADO', 'ENTREGUE', 'CANCELADO')),
    CONSTRAINT check_valor_total_positivo CHECK (valor_total >= 0),
    CONSTRAINT check_data_entrega_futura CHECK (data_entrega IS NULL OR data_entrega >= CURRENT_DATE)
);

CREATE TABLE loja.item_pedido (
    id_item_pedido SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unitario NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(12, 2) NOT NULL,
    desconto NUMERIC(10, 2) DEFAULT 0,
    CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) 
        REFERENCES loja.pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) 
        REFERENCES loja.produto(id_produto) ON DELETE RESTRICT,
    CONSTRAINT check_quantidade_positiva CHECK (quantidade > 0),
    CONSTRAINT check_preco_unitario_positivo CHECK (preco_unitario > 0),
    CONSTRAINT check_subtotal_correto CHECK (subtotal = (preco_unitario * quantidade) - desconto),
    CONSTRAINT check_desconto_nao_negativo CHECK (desconto >= 0)
);

CREATE TABLE loja.log_estoque (
    id_log SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    operacao VARCHAR(20) NOT NULL,
    quantidade_anterior INTEGER,
    quantidade_nova INTEGER,
    data_operacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(50) DEFAULT CURRENT_USER,
    observacao TEXT
);

-- ================================================================================
-- ÍNDICES PARA OTIMIZAÇÃO
-- ================================================================================

CREATE INDEX idx_pedido_data ON loja.pedido(data_pedido);
CREATE INDEX idx_pedido_status ON loja.pedido(status);
CREATE INDEX idx_pedido_cliente ON loja.pedido(id_cliente);
CREATE INDEX idx_produto_categoria ON loja.produto(id_categoria);
CREATE INDEX idx_produto_nome ON loja.produto USING gin(to_tsvector('portuguese', nome));
CREATE INDEX idx_item_pedido_produto ON loja.item_pedido(id_pedido, id_produto);

-- ================================================================================
-- DICIONÁRIO DE DADOS
-- ================================================================================

COMMENT ON TABLE loja.cliente IS 'Dados cadastrais dos clientes';
COMMENT ON TABLE loja.categoria IS 'Categorias de produtos';
COMMENT ON TABLE loja.produto IS 'Catálogo de produtos';
COMMENT ON TABLE loja.estoque IS 'Controle de estoque';
COMMENT ON TABLE loja.pedido IS 'Pedidos realizados';
COMMENT ON TABLE loja.item_pedido IS 'Itens dos pedidos';
COMMENT ON TABLE loja.log_estoque IS 'Histórico de movimentações';

COMMENT ON COLUMN loja.cliente.cpf IS 'CPF no formato XXX.XXX.XXX-XX';
COMMENT ON COLUMN loja.produto.preco IS 'Preço unitário em reais';
COMMENT ON COLUMN loja.estoque.quantidade IS 'Quantidade disponível';

-- ================================================================================
-- POVOAMENTO DE DADOS
-- ================================================================================

INSERT INTO loja.categoria (nome, descricao) VALUES
('Eletrônicos', 'Notebooks, smartphones, tablets'),
('Roupas Masculinas', 'Vestuário masculino'),
('Roupas Femininas', 'Vestuário feminino'),
('Calçados', 'Tênis, sapatos e sandálias'),
('Acessórios', 'Relógios, bolsas, cintos');

INSERT INTO loja.cliente (nome, cpf, email, telefone, data_nascimento, logradouro, numero, bairro, cidade, estado, cep) VALUES
('João Silva Santos', '123.456.789-10', 'joao.silva@email.com', '(61) 98765-4321', '1990-05-15', 'SQN 210 Bloco A', '101', 'Asa Norte', 'Brasília', 'DF', '70862-010'),
('Maria Oliveira Costa', '234.567.890-11', 'maria.oliveira@email.com', '(61) 99876-5432', '1985-08-22', 'SQSW 300 Bloco B', '202', 'Sudoeste', 'Brasília', 'DF', '70673-402'),
('Pedro Henrique Souza', '345.678.901-12', 'pedro.souza@email.com', '(61) 97765-4321', '1992-11-10', 'QS 05 Rua 100', '303', 'Areal', 'Águas Claras', 'DF', '71966-700'),
('Ana Paula Ferreira', '456.789.012-13', 'ana.ferreira@email.com', '(61) 96654-3210', '1988-03-28', 'Rua 12 Norte', '404', 'Águas Claras', 'Águas Claras', 'DF', '71908-180'),
('Carlos Eduardo Lima', '567.890.123-14', 'carlos.lima@email.com', '(61) 95543-2109', '1995-07-05', 'QNM 36 Conjunto G', '505', 'Ceilândia Norte', 'Ceilândia', 'DF', '72146-407'),
('Juliana Martins Rocha', '678.901.234-15', 'juliana.rocha@email.com', '(61) 94432-1098', '1993-12-18', 'SHIN QI 09', '606', 'Lago Norte', 'Brasília', 'DF', '71515-090'),
('Roberto Carlos Alves', '789.012.345-16', 'roberto.alves@email.com', '(61) 93321-0987', '1987-09-30', 'SQS 116 Bloco F', '707', 'Asa Sul', 'Brasília', 'DF', '70377-060');

INSERT INTO loja.produto (id_categoria, nome, descricao, preco, peso_kg, marca, modelo, cor, tamanho) VALUES
(1, 'Notebook Dell Inspiron 15', 'Notebook Intel i5, 8GB RAM', 3299.90, 1.850, 'Dell', 'Inspiron 15', 'Preto', NULL),
(1, 'Smartphone Samsung Galaxy A54', 'Smartphone 5G 128GB', 1899.00, 0.202, 'Samsung', 'Galaxy A54', 'Azul', NULL),
(1, 'Tablet iPad 10ª Geração', 'Tablet Apple 10.9 pol', 2699.00, 0.477, 'Apple', 'iPad 10', 'Prata', NULL),
(1, 'Fone Bluetooth JBL', 'Fone wireless', 199.90, 0.160, 'JBL', 'Tune 510BT', 'Branco', NULL),
(1, 'Mouse Gamer Logitech', 'Mouse óptico HERO 25K', 249.90, 0.087, 'Logitech', 'G403', 'Preto', NULL),
(2, 'Camiseta Polo Ralph Lauren', 'Polo 100% algodão', 189.90, 0.200, 'Ralph Lauren', 'Classic Fit', 'Azul', 'M'),
(2, 'Calça Jeans Levis 511', 'Calça slim fit', 349.90, 0.550, 'Levis', '511 Slim', 'Azul', '42'),
(2, 'Jaqueta Nike Sportswear', 'Jaqueta corta-vento', 399.90, 0.450, 'Nike', 'Windrunner', 'Preta', 'G'),
(3, 'Vestido Floral Zara', 'Vestido midi', 259.90, 0.300, 'Zara', 'Summer', 'Floral', 'P'),
(3, 'Blusa de Seda Animale', 'Blusa manga longa', 429.90, 0.150, 'Animale', 'Elegant', 'Off-White', 'M'),
(4, 'Tênis Nike Air Max 90', 'Tênis casual Air', 699.90, 0.800, 'Nike', 'Air Max 90', 'Branco', '40'),
(4, 'Bota Timberland Yellow', 'Bota impermeável', 899.90, 1.200, 'Timberland', '6-Inch', 'Amarelo', '42'),
(5, 'Relógio Casio G-Shock', 'Relógio digital', 549.90, 0.070, 'Casio', 'G-Shock', 'Preto', NULL),
(5, 'Mochila Kipling Seoul', 'Mochila 27L', 389.90, 0.380, 'Kipling', 'Seoul', 'Cinza', NULL),
(5, 'Óculos Ray-Ban Aviador', 'Óculos proteção UV', 459.90, 0.030, 'Ray-Ban', 'Aviator', 'Dourado', NULL);

INSERT INTO loja.estoque (id_produto, quantidade, quantidade_minima, localizacao) VALUES
(1, 15, 5, 'A-01-02'), (2, 30, 10, 'A-01-03'), (3, 12, 5, 'A-01-04'),
(4, 50, 15, 'B-02-01'), (5, 40, 10, 'B-02-02'), (6, 25, 8, 'C-03-01'),
(7, 35, 10, 'C-03-02'), (8, 20, 8, 'C-03-03'), (9, 30, 10, 'D-04-01'),
(10, 18, 6, 'D-04-02'), (11, 22, 8, 'E-05-01'), (12, 15, 5, 'E-05-02'),
(13, 28, 10, 'F-06-01'), (14, 12, 5, 'F-06-02'), (15, 35, 12, 'F-06-03');

INSERT INTO loja.pedido (id_cliente, data_pedido, status, valor_total, forma_pagamento) VALUES
(1, '2024-06-15 10:30:00', 'ENTREGUE', 3499.80, 'Cartão de Crédito'),
(2, '2024-07-20 14:45:00', 'ENTREGUE', 1899.00, 'PIX'),
(1, '2024-08-05 09:15:00', 'ENTREGUE', 1379.60, 'Boleto'),
(3, '2024-08-22 16:20:00', 'ENTREGUE', 2699.00, 'Cartão de Crédito'),
(4, '2024-09-10 11:00:00', 'ENTREGUE', 1389.70, 'PIX'),
(5, '2024-09-28 13:40:00', 'ENVIADO', 699.90, 'Cartão'),
(2, '2024-10-12 15:30:00', 'ENTREGUE', 539.80, 'Cartão de Crédito'),
(6, '2024-10-25 10:50:00', 'PROCESSANDO', 1449.60, 'PIX'),
(3, '2024-11-08 14:10:00', 'ENTREGUE', 459.90, 'Cartão'),
(7, '2024-11-20 09:25:00', 'PROCESSANDO', 1129.60, 'Boleto'),
(1, '2024-11-30 16:45:00', 'PENDENTE', 849.70, 'PIX'),
(4, '2024-12-05 11:15:00', 'PENDENTE', 2328.90, 'Cartão'),
(5, '2024-12-08 13:50:00', 'PENDENTE', 689.80, 'PIX');

INSERT INTO loja.item_pedido (id_pedido, id_produto, quantidade, preco_unitario, subtotal) VALUES
(1, 1, 1, 3299.90, 3299.90), (1, 4, 1, 199.90, 199.90),
(2, 2, 1, 1899.00, 1899.00),
(3, 6, 2, 189.90, 379.80), (3, 13, 1, 549.90, 549.90), (3, 5, 2, 249.90, 499.80),
(4, 3, 1, 2699.00, 2699.00),
(5, 9, 1, 259.90, 259.90), (5, 10, 1, 429.90, 429.90), (5, 11, 1, 699.90, 699.90),
(6, 11, 1, 699.90, 699.90),
(7, 6, 1, 189.90, 189.90), (7, 7, 1, 349.90, 349.90),
(8, 8, 1, 399.90, 399.90), (8, 14, 1, 389.90, 389.90), (8, 4, 1, 199.90, 199.90), (8, 15, 1, 459.90, 459.90),
(9, 15, 1, 459.90, 459.90),
(10, 6, 2, 189.90, 379.80), (10, 13, 1, 549.90, 549.90), (10, 4, 1, 199.90, 199.90),
(11, 7, 1, 349.90, 349.90), (11, 5, 2, 249.90, 499.80),
(12, 2, 1, 1899.00, 1899.00), (12, 10, 1, 429.90, 429.90),
(13, 9, 1, 259.90, 259.90), (13, 10, 1, 429.90, 429.90);

-- ================================================================================
-- AUTOMAÇÃO - TRIGGER
-- ================================================================================

CREATE OR REPLACE FUNCTION loja.fn_atualizar_estoque_apos_venda()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $func$
BEGIN
    UPDATE loja.estoque
    SET quantidade = quantidade - NEW.quantidade,
        ultima_atualizacao = CURRENT_TIMESTAMP
    WHERE id_produto = NEW.id_produto;
    
    INSERT INTO loja.log_estoque (id_produto, operacao, quantidade_anterior, quantidade_nova, observacao)
    SELECT 
        NEW.id_produto,
        'VENDA',
        e.quantidade + NEW.quantidade,
        e.quantidade,
        'Venda pedido #' || NEW.id_pedido
    FROM loja.estoque e
    WHERE e.id_produto = NEW.id_produto;
    
    RETURN NEW;
END;
$func$;

CREATE TRIGGER trg_atualizar_estoque
AFTER INSERT ON loja.item_pedido
FOR EACH ROW
EXECUTE FUNCTION loja.fn_atualizar_estoque_apos_venda();

-- ================================================================================
-- AUTOMAÇÃO - PROCEDURE COM CONTROLE DE CONCORRÊNCIA
-- ================================================================================

CREATE OR REPLACE PROCEDURE loja.realizar_compra(
    p_id_cliente INTEGER,
    p_id_produto INTEGER,
    p_quantidade INTEGER,
    p_forma_pagamento VARCHAR
)
LANGUAGE plpgsql
AS $proc$
DECLARE
    v_preco NUMERIC(10, 2);
    v_subtotal NUMERIC(12, 2);
    v_estoque INTEGER;
    v_id_pedido INTEGER;
    v_nome VARCHAR(150);
BEGIN
    IF NOT EXISTS (SELECT 1 FROM loja.cliente WHERE id_cliente = p_id_cliente AND ativo = TRUE) THEN
        RAISE EXCEPTION 'Cliente inválido: %', p_id_cliente;
    END IF;
    
    IF p_quantidade <= 0 THEN
        RAISE EXCEPTION 'Quantidade deve ser maior que zero';
    END IF;
    
    SELECT p.preco, p.nome, e.quantidade
    INTO v_preco, v_nome, v_estoque
    FROM loja.produto p
    INNER JOIN loja.estoque e ON p.id_produto = e.id_produto
    WHERE p.id_produto = p_id_produto AND p.ativo = TRUE
    FOR UPDATE OF e;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Produto não encontrado: %', p_id_produto;
    END IF;
    
    IF v_estoque < p_quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente para "%". Disponível: %, Solicitado: %', 
            v_nome, v_estoque, p_quantidade;
    END IF;
    
    v_subtotal := v_preco * p_quantidade;
    
    INSERT INTO loja.pedido (id_cliente, status, valor_total, forma_pagamento)
    VALUES (p_id_cliente, 'PENDENTE', v_subtotal, p_forma_pagamento)
    RETURNING id_pedido INTO v_id_pedido;
    
    INSERT INTO loja.item_pedido (id_pedido, id_produto, quantidade, preco_unitario, subtotal)
    VALUES (v_id_pedido, p_id_produto, p_quantidade, v_preco, v_subtotal);
    
    RAISE NOTICE 'Compra realizada! Pedido: %', v_id_pedido;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Erro ao processar: %', SQLERRM;
END;
$proc$;

-- ================================================================================
-- VIEW COM DADOS MASCARADOS
-- ================================================================================

CREATE OR REPLACE VIEW loja.vw_cliente_publico AS
SELECT 
    id_cliente,
    nome,
    '***.***.***-' || RIGHT(cpf, 2) AS cpf_mascarado,
    LEFT(email, 3) || '***@' || SPLIT_PART(email, '@', 2) AS email_mascarado,
    cidade,
    estado,
    ativo,
    DATE_PART('year', AGE(CURRENT_DATE, data_cadastro)) AS anos_cliente
FROM loja.cliente
WHERE ativo = TRUE;

-- ================================================================================
-- FUNCTION DE RELATÓRIO
-- ================================================================================

CREATE OR REPLACE FUNCTION loja.relatorio_vendas_periodo(
    p_mes INTEGER,
    p_ano INTEGER
)
RETURNS TABLE (
    id_pedido INTEGER,
    data_pedido TIMESTAMP,
    nome_cliente VARCHAR,
    qtd_itens BIGINT,
    valor_total NUMERIC,
    status VARCHAR,
    forma_pagamento VARCHAR
) 
LANGUAGE plpgsql
AS $func_relat$
BEGIN
    RETURN QUERY
    SELECT 
        p.id_pedido,
        p.data_pedido,
        c.nome,
        COUNT(ip.id_item_pedido),
        p.valor_total,
        p.status,
        p.forma_pagamento
    FROM loja.pedido p
    INNER JOIN loja.cliente c ON p.id_cliente = c.id_cliente
    LEFT JOIN loja.item_pedido ip ON p.id_pedido = ip.id_pedido
    WHERE EXTRACT(MONTH FROM p.data_pedido) = p_mes
      AND EXTRACT(YEAR FROM p.data_pedido) = p_ano
    GROUP BY p.id_pedido, p.data_pedido, c.nome, p.valor_total, p.status, p.forma_pagamento
    ORDER BY p.data_pedido DESC;
END;
$func_relat$;

-- ================================================================================
-- CONSULTAS AVANÇADAS
-- ================================================================================

-- CONSULTA 1: CTE + Window Functions
WITH vendas_cliente AS (
    SELECT 
        c.id_cliente,
        c.nome,
        c.cidade,
        COUNT(DISTINCT p.id_pedido) AS total_pedidos,
        COALESCE(SUM(p.valor_total), 0) AS valor_gasto
    FROM loja.cliente c
    LEFT JOIN loja.pedido p ON c.id_cliente = p.id_cliente
    WHERE c.ativo = TRUE
    GROUP BY c.id_cliente, c.nome, c.cidade
),
ranking AS (
    SELECT 
        nome,
        cidade,
        total_pedidos,
        valor_gasto,
        RANK() OVER (ORDER BY valor_gasto DESC) AS posicao,
        PERCENT_RANK() OVER (ORDER BY valor_gasto DESC) AS percentil
    FROM vendas_cliente
)
SELECT 
    posicao,
    nome,
    cidade,
    total_pedidos,
    TO_CHAR(valor_gasto, 'FM999G999D00') AS valor_gasto,
    ROUND((percentil * 100)::NUMERIC, 2) || '%' AS percentil
FROM ranking
WHERE valor_gasto > 0
ORDER BY posicao;

-- CONSULTA 2: Subconsultas Aninhadas
SELECT 
    p.id_produto,
    p.nome,
    cat.nome AS categoria,
    COUNT(ip.id_item_pedido) AS vendas,
    TO_CHAR(SUM(ip.subtotal), 'FM999G999D00') AS receita
FROM loja.produto p
INNER JOIN loja.categoria cat ON p.id_categoria = cat.id_categoria
LEFT JOIN loja.item_pedido ip ON p.id_produto = ip.id_produto
WHERE p.id_produto IN (
    SELECT ip2.id_produto
    FROM loja.item_pedido ip2
    GROUP BY ip2.id_produto
    HAVING SUM(ip2.subtotal) > (
        SELECT AVG(receita_produto)
        FROM (
            SELECT SUM(subtotal) AS receita_produto
            FROM loja.item_pedido
            GROUP BY id_produto
        ) AS sub
    )
)
GROUP BY p.id_produto, p.nome, cat.nome
ORDER BY SUM(ip.subtotal) DESC;

-- CONSULTA 3: LAG, LEAD e Média Móvel
WITH vendas_mes AS (
    SELECT 
        TO_CHAR(data_pedido, 'YYYY-MM') AS mes,
        DATE_TRUNC('month', data_pedido) AS mes_data,
        COUNT(DISTINCT id_pedido) AS qtd_pedidos,
        SUM(valor_total) AS receita
    FROM loja.pedido
    WHERE status != 'CANCELADO'
    GROUP BY TO_CHAR(data_pedido, 'YYYY-MM'), DATE_TRUNC('month', data_pedido)
)
SELECT 
    mes,
    qtd_pedidos,
    TO_CHAR(receita, 'FM999G999D00') AS receita,
    LAG(receita, 1) OVER (ORDER BY mes_data) AS receita_anterior,
    LEAD(receita, 1) OVER (ORDER BY mes_data) AS receita_seguinte,
    AVG(receita) OVER (
        ORDER BY mes_data 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS media_movel_3m
FROM vendas_mes
ORDER BY mes_data;

-- CONSULTA 4: UNION, INTERSECT, EXCEPT
WITH cli_eletro AS (
    SELECT DISTINCT c.id_cliente, c.nome
    FROM loja.cliente c
    INNER JOIN loja.pedido p ON c.id_cliente = p.id_cliente
    INNER JOIN loja.item_pedido ip ON p.id_pedido = ip.id_pedido
    INNER JOIN loja.produto prod ON ip.id_produto = prod.id_produto
    WHERE prod.id_categoria = 1
),
cli_roupa AS (
    SELECT DISTINCT c.id_cliente, c.nome
    FROM loja.cliente c
    INNER JOIN loja.pedido p ON c.id_cliente = p.id_cliente
    INNER JOIN loja.item_pedido ip ON p.id_pedido = ip.id_pedido
    INNER JOIN loja.produto prod ON ip.id_produto = prod.id_produto
    WHERE prod.id_categoria IN (2, 3)
),
ambos AS (
    SELECT id_cliente, nome FROM cli_eletro
    INTERSECT
    SELECT id_cliente, nome FROM cli_roupa
),
so_eletro AS (
    SELECT id_cliente, nome FROM cli_eletro
    EXCEPT
    SELECT id_cliente, nome FROM cli_roupa
)
SELECT id_cliente, nome, 'Eletrônicos e Roupas' AS tipo FROM ambos
UNION ALL
SELECT id_cliente, nome, 'Só Eletrônicos' AS tipo FROM so_eletro
UNION ALL
SELECT id_cliente, nome, 'Só Roupas' AS tipo 
FROM cli_roupa
WHERE id_cliente NOT IN (SELECT id_cliente FROM cli_eletro)
ORDER BY tipo, nome;

-- CONSULTA 5: Filtros Complexos + ROLLUP
SELECT 
    COALESCE(cat.nome, 'TOTAL') AS categoria,
    COALESCE(
        CASE 
            WHEN p.preco < 300 THEN 'Até R$ 300'
            WHEN p.preco BETWEEN 300 AND 1000 THEN 'R$ 300-1000'
            ELSE 'Acima R$ 1000'
        END,
        'TODAS'
    ) AS faixa,
    COUNT(DISTINCT p.id_produto) AS produtos,
    COUNT(ip.id_item_pedido) AS vendas,
    TO_CHAR(SUM(ip.subtotal), 'FM999G999D00') AS receita
FROM loja.categoria cat
LEFT JOIN loja.produto p ON cat.id_categoria = p.id_categoria
LEFT JOIN loja.item_pedido ip ON p.id_produto = ip.id_produto
LEFT JOIN loja.pedido ped ON ip.id_pedido = ped.id_pedido
WHERE 
    p.ativo = TRUE
    AND (ped.data_pedido >= CURRENT_DATE - INTERVAL '6 months' OR ped.data_pedido IS NULL)
    AND (ped.status IN ('ENTREGUE', 'ENVIADO', 'PROCESSANDO') OR ped.status IS NULL)
GROUP BY ROLLUP(cat.nome, 
    CASE 
        WHEN p.preco < 300 THEN 'Até R$ 300'
        WHEN p.preco BETWEEN 300 AND 1000 THEN 'R$ 300-1000'
        ELSE 'Acima R$ 1000'
    END
)
ORDER BY 
    CASE WHEN cat.nome IS NULL THEN 1 ELSE 0 END,
    categoria;

-- ================================================================================
-- AMBIENTE ANALÍTICO - OLAP
-- ================================================================================

CREATE SCHEMA analitico;

CREATE TABLE analitico.dim_cliente (
    sk_cliente SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    nome VARCHAR(100),
    cidade VARCHAR(50),
    estado CHAR(2),
    data_cadastro DATE,
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE analitico.dim_produto (
    sk_produto SERIAL PRIMARY KEY,
    id_produto INTEGER NOT NULL,
    nome_produto VARCHAR(150),
    categoria VARCHAR(50),
    marca VARCHAR(50),
    preco_atual NUMERIC(10, 2),
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE analitico.dim_tempo (
    sk_tempo SERIAL PRIMARY KEY,
    data DATE NOT NULL UNIQUE,
    dia INTEGER,
    mes INTEGER,
    mes_nome VARCHAR(20),
    trimestre INTEGER,
    ano INTEGER,
    dia_semana INTEGER,
    dia_semana_nome VARCHAR(20),
    fim_de_semana BOOLEAN
);

CREATE TABLE analitico.fato_vendas (
    sk_fato_vendas SERIAL PRIMARY KEY,
    sk_cliente INTEGER REFERENCES analitico.dim_cliente(sk_cliente),
    sk_produto INTEGER REFERENCES analitico.dim_produto(sk_produto),
    sk_tempo INTEGER REFERENCES analitico.dim_tempo(sk_tempo),
    id_pedido INTEGER,
    quantidade INTEGER,
    preco_unitario NUMERIC(10, 2),
    subtotal NUMERIC(12, 2),
    desconto NUMERIC(10, 2),
    valor_liquido NUMERIC(12, 2),
    data_carga TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_fato_cliente ON analitico.fato_vendas(sk_cliente);
CREATE INDEX idx_fato_produto ON analitico.fato_vendas(sk_produto);
CREATE INDEX idx_fato_tempo ON analitico.fato_vendas(sk_tempo);

-- ================================================================================
-- PROCEDURE DE ETL
-- ================================================================================

CREATE OR REPLACE PROCEDURE analitico.executar_etl()
LANGUAGE plpgsql
AS $etl$
DECLARE
    v_registros INTEGER := 0;
BEGIN
    INSERT INTO analitico.dim_tempo (data, dia, mes, mes_nome, trimestre, ano, dia_semana, dia_semana_nome, fim_de_semana)
    SELECT 
        data::DATE,
        EXTRACT(DAY FROM data)::INTEGER,
        EXTRACT(MONTH FROM data)::INTEGER,
        TO_CHAR(data, 'TMMonth'),
        EXTRACT(QUARTER FROM data)::INTEGER,
        EXTRACT(YEAR FROM data)::INTEGER,
        EXTRACT(ISODOW FROM data)::INTEGER,
        TO_CHAR(data, 'TMDay'),
        EXTRACT(ISODOW FROM data) IN (6, 7)
    FROM generate_series('2024-01-01'::DATE, CURRENT_DATE + INTERVAL '5 years', '1 day'::INTERVAL) AS data
    ON CONFLICT (data) DO NOTHING;
    
    TRUNCATE TABLE analitico.fato_vendas CASCADE;
    TRUNCATE TABLE analitico.dim_cliente CASCADE;
    TRUNCATE TABLE analitico.dim_produto CASCADE;
    
    INSERT INTO analitico.dim_cliente (id_cliente, nome, cidade, estado, data_cadastro)
    SELECT id_cliente, nome, cidade, estado, data_cadastro::DATE
    FROM loja.cliente WHERE ativo = TRUE;
    
    INSERT INTO analitico.dim_produto (id_produto, nome_produto, categoria, marca, preco_atual)
    SELECT p.id_produto, p.nome, c.nome, p.marca, p.preco
    FROM loja.produto p
    INNER JOIN loja.categoria c ON p.id_categoria = c.id_categoria
    WHERE p.ativo = TRUE;
    
    INSERT INTO analitico.fato_vendas (sk_cliente, sk_produto, sk_tempo, id_pedido, quantidade, preco_unitario, subtotal, desconto, valor_liquido)
    SELECT dc.sk_cliente, dp.sk_produto, dt.sk_tempo, p.id_pedido, ip.quantidade, ip.preco_unitario, ip.subtotal, ip.desconto, ip.subtotal
    FROM loja.pedido p
    INNER JOIN loja.cliente c ON p.id_cliente = c.id_cliente
    INNER JOIN loja.item_pedido ip ON p.id_pedido = ip.id_pedido
    INNER JOIN loja.produto prod ON ip.id_produto = prod.id_produto
    INNER JOIN analitico.dim_cliente dc ON c.id_cliente = dc.id_cliente
    INNER JOIN analitico.dim_produto dp ON prod.id_produto = dp.id_produto
    INNER JOIN analitico.dim_tempo dt ON p.data_pedido::DATE = dt.data
    WHERE p.status != 'CANCELADO';
    
    GET DIAGNOSTICS v_registros = ROW_COUNT;
    RAISE NOTICE 'ETL executado! % registros carregados.', v_registros;
END;
$etl$;

CALL analitico.executar_etl();

-- ================================================================================
-- VIEW MATERIALIZADA PARA DASHBOARD
-- ================================================================================

CREATE MATERIALIZED VIEW analitico.mv_dashboard_vendas AS
SELECT 
    dt.ano,
    dt.mes,
    dt.mes_nome,
    dp.categoria,
    COUNT(DISTINCT fv.id_pedido) AS qtd_pedidos,
    SUM(fv.quantidade) AS unidades_vendidas,
    SUM(fv.valor_liquido) AS receita_total,
    AVG(fv.valor_liquido) AS ticket_medio,
    COUNT(DISTINCT fv.sk_cliente) AS clientes_unicos
FROM analitico.fato_vendas fv
INNER JOIN analitico.dim_tempo dt ON fv.sk_tempo = dt.sk_tempo
INNER JOIN analitico.dim_produto dp ON fv.sk_produto = dp.sk_produto
GROUP BY dt.ano, dt.mes, dt.mes_nome, dp.categoria
WITH DATA;

CREATE INDEX idx_mv_ano_mes ON analitico.mv_dashboard_vendas(ano, mes);
CREATE INDEX idx_mv_categoria ON analitico.mv_dashboard_vendas(categoria);

COMMENT ON MATERIALIZED VIEW analitico.mv_dashboard_vendas IS 'Dashboard de vendas por mês e categoria';

-- ================================================================================
-- COMANDOS DE MANUTENÇÃO
-- ================================================================================

-- Para atualizar a view materializada (executar periodicamente):
-- REFRESH MATERIALIZED VIEW analitico.mv_dashboard_vendas;

-- Para manutenção do banco:
-- VACUUM ANALYZE;
-- REINDEX DATABASE postgres;

-- ================================================================================
-- TESTES
-- ================================================================================

-- Testar procedure de compra
-- CALL loja.realizar_compra(1, 5, 2, 'PIX');

-- Consultar view de clientes
-- SELECT * FROM loja.vw_cliente_publico;

-- Consultar relatório de vendas
-- SELECT * FROM loja.relatorio_vendas_periodo(11, 2024);

-- Consultar dashboard analítico
-- SELECT * FROM analitico.mv_dashboard_vendas ORDER BY ano DESC, mes DESC;

-- ================================================================================
-- FIM DO SCRIPT
-- ================================================================================

SELECT 'Script executado com sucesso!' AS mensagem;