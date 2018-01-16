CREATE TABLE public.produto(
	num_produto integer primary key,
	nome varchar(30),
	preco numeric(5,2)
)with OIDS;

CREATE TABLE public.pedido(
	num_pedido integer primary key,
	address text
)WITH OIDS;

CREATE TABLE public.itens_pedido(
	num_produto integer,
	num_pedido integer,
	quantidade integer,
	primary key(num_produto, num_pedido),
	foreign key (num_produto) references public.produto(num_produto) ON DELETE RESTRICT,
	foreign key (num_pedido) references public.pedido (num_pedido) ON DELETE CASCADE
)WITH OIDS;

-- ISERÇÃO DE DADOS
--PRODUTOS
INSERT INTO produto (num_produto, nome, preco) values (10, 'Arroz', 3.45);
INSERT INTO produto (num_produto, nome, preco) values (11, 'Feijão', 3.55);
INSERT INTO produto (num_produto, nome, preco) values (12, 'Café', 2.25);
INSERT INTO produto (num_produto, nome, preco) values (13, 'Açucar',3.75);
INSERT INTO produto (num_produto, nome, preco) values (14, 'Farinha',4.75);

--PEDIDOS
INSERT INTO pedido (num_pedido, address) values(1, 'rua Nonato Mota, 809');
INSERT INTO pedido (num_pedido, address) values(2, 'Rua Nossa Senhara de Fátima, 873');
INSERT INTO pedido (num_pedido, address) values(3, 'Rua do sol Poente, 10');

--ADICIONANDO ITENS NO PEDIDO 1
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (10, 1, 15);
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (11, 1, 3);
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (12, 1, 1);
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (13, 1, 2);

--ADICIONANDO ITENS NO PEDIDO 2
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (10, 2, 1);
INSERT INTO itens_pedido (num_produto, num_pedido, quantidade) values (11, 2, 3);

delete from pedido where num_pedido = 2 -- O pedido será excluido juntamente com todos os seus itens em cascata
delete from produto where num_produto = 12 -- Esta exclusão não é permitida, pois o produto está sendo referenciado por um itens_pedido


select * from itens_pedido
select * from produto
select * from pedido

select pedido.num_pedido, produto.nome, itens_pedido.quantidade, pedido.address
from produto join itens_pedido
on produto.num_produto = itens_pedido.num_produto
inner join pedido
on pedido.num_pedido = itens_pedido.num_pedido
where pedido.num_pedido = 2;

delete from produto where num_produto = 15



start transaction;
	select * from produto;
	INSERT INTO produto (num_produto, nome, preco) values (15, 'pro_teste',4.75);
	select * from produto;
commit;
