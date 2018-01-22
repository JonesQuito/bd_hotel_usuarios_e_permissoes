select usename from pg_user; --Lista os usuários de banco de dados
select current_user -- Exibe o usuário atual
select groname from pg_group; -- Lista os grupos de usuários(papeis) de banco de dados


CREATE DATABASE hotel; -- Comando para criação do banco de dados hotel

-- CRIA A TABELA DE CLIENTES
CREATE TABLE cliente(
	rg numeric not null,
	nome varchar(40) not null,
	sexo char(1) not null,
	telefone numeric(10,0),
	primary key (rg)
)without oids;

-- Tabela TIPO_QUARTO
CREATE TABLE tipo_quarto(
	id_tipo SERIAL NOT NULL,
	descricao varchar(40) NOT NULL,
	valor NUMERIC(9,2) NOT NULL,
	primary key (id_tipo)
)WITHOUT OIDS;

-- Tabela QUARTO
CREATE TABLE quarto(
	num_quarto INTEGER NOT NULL,
	andar VARCHAR(10),
	id_tipo INTEGER NOT NULL,
	status CHAR(1) NOT NULL DEFAULT 'D',
	primary key (num_quarto),
	foreign key(id_tipo) references tipo_quarto (id_tipo)
	
)WITHOUT OIDS;

-- Tabela SERVIÇO
CREATE TABLE servico(
	id_servico SERIAL NOT NULL,
	descricao VARCHAR(60) NOT NULL,
	valor NUMERIC(9,2) NOT NULL,
	PRIMARY KEY (id_servico)
)WITHOUT OIDS;

DROP TABLE servico

-- Tabela RESERVA
CREATE TABLE reserva(
	id_reserva SERIAL NOT NULL,
	rg NUMERIC NOT NULL,
	num_quarto INTEGER NOT NULL,
	dt_reserva DATE NOT NULL,
	qtd_dias INTEGER NOT NULL,
	data_entrada DATE NOT NULL,
	status CHAR(1) NOT NULL DEFAULT 'A',
	PRIMARY KEY (id_reserva),
	FOREIGN KEY (rg) REFERENCES cliente (rg) ON UPDATE RESTRICT ON DELETE RESTRICT,
	FOREIGN KEY (num_quarto) REFERENCES quarto (num_quarto) ON UPDATE RESTRICT ON DELETE RESTRICT
	
)WITHOUT OIDS;



-- Tabela HOSPEDAGEM
CREATE TABLE hospedagem(
	id_hospedagem SERIAL NOT NULL,
	rg NUMERIC NOT NULL,
	num_quarto INTEGER NOT NULL,
	data_entrada DATE NOT NULL,
	data_saida DATE,
	status CHAR(1) NOT NULL,
	PRIMARY KEY (id_hospedagem),
	FOREIGN KEY (rg) REFERENCES cliente(rg) ON UPDATE RESTRICT ON DELETE RESTRICT,
	FOREIGN KEY (num_quarto) REFERENCES quarto (num_quarto) ON UPDATE RESTRICT ON DELETE RESTRICT
)WITHOUT OIDS;

-- Tabela ATENDIMENTO
CREATE TABLE atendimento(
	id_atendimento SERIAL NOT NULL,
	id_servico INTEGER NOT NULL,
	id_hospedagem INTEGER NOT NULL,
	PRIMARY KEY (id_atendimento),
	FOREIGN KEY (id_servico) REFERENCES servico (id_servico) ON UPDATE RESTRICT ON DELETE RESTRICT,
	FOREIGN KEY (id_hospedagem) REFERENCES hospedagem (id_hospedagem) ON UPDATE RESTRICT ON DELETE RESTRICT
)WITHOUT OIDS;




-- Função para adicionar hospedagem
CREATE OR REPLACE FUNCTION adicionaHospedagem(re_cliente numeric, numero_quarto int) RETURNS void AS
  $$
  BEGIN
	perform * from cliente where rg = rg_cliente;
	if found then
		perform * from quarto where upper(status) = 'D' and num_quarto = numero_quarto;
		if found then
			insert into hospedagem values (default, rg_cliente, numero_quarto, current_date, null, 'A');
			update quarto set status = 'O' where num_quarto = numero_quarto;
			RAISE NOTICE 'Hospedagem realizada com sucesso!';
		else
			RAISE NOTICE 'Quarto indisponível para hospedagem!';
		end if;
	else
		RAISE EXCEPTION 'Clinte não consta no cadastro';
	end if;
  END;
  $$
  LANGUAGE plpgsql SECURITY DEFINER;




-- FUNÇÃO PARA ADICIONAR RESERVA
CREATE OR REPLACE FUNCTION adicionaReserva(rg_cliente numeric, numero_quarto int, dias int, data_entrada date) RETURNS void AS
$$
begin
perform * from cliente where rg = rg_cliente;
if found then
	perform * from quarto where upper(status) = 'D' and num_quarto = numero_quarto;
	if found then
		insert into reserva values(default, rg_cliente, numero_quarto, current_date, dias, data_entrada, 'A');
		update quarto set status = 'R' where num_quarto = numero_quarto;
		RAISE NOTICE 'Reserva realizada com sucesso!';
	else
		RAISE EXCEPTION 'Quarto indisponível para reserva!';
	end if;
else
	RAISE EXCEPTION 'Cliente não consta no cadastro!';
end if;
end;
$$
LANGUAGE plpgsql SECURITY DEFINER;




-- FUNÇÃO PARA REALIZAR PEDIDO
CREATE OR REPLACE FUNCTION realizaPedido(hosp int, serv int) RETURNS void AS
$$
begin
	perform * from hospedagem where upper(status) = 'A' and id_hospedagem = hosp;
	if found then
		perform * from servico where id_servico = serv ;
		if found then
			insert into atendimento values(default, serv, hosp);
			RAISE NOTICE 'Pedido realizado com sucesso!';
		else
			RAISE EXCEPTION 'Serviço indisponível!';
		end if;
	else
		RAISE EXCEPTION 'Hospedagem não consta no sistema ou já foi desatualzada!';
	end if;
end;
$$
LANGUAGE plpgsql SECURITY DEFINER;



-- VIEW DE LISTAGEM SIMPLES DE CLIENTES
CREATE VIEW listaClientes(nome_cliente, sexo) AS
	SELECT nome, sexo FROM cliente


-- CRIANDO OS PAPÉIS - USUÁRIOS
CREATE ROLE gerente;
CREATE ROLE atendente;
CREATE ROLE estagiario;

--REVOGANDO O DIREITO DE TODOS OS USUÁRIOS PRA EXECUTAR AS FUNÇÕES DE adicionarReserva(), adicionarHospedagem() e realizarPedido()
REVOKE ALL ON FUNCTION adicionaReserva(numeric, int, int, date) FROM PUBLIC;
REVOKE ALL ON FUNCTION adicionaHospedagem(numeric, int) FROM PUBLIC;
REVOKE ALL ON FUNCTION realizaPedido(int, int) FROM PUBLIC;



/* ##########  CONCEDENDO PERMISSÕES DO GERENTE  ##########*/

--CONCEDENDO PERMISSÕES PARA O ROLE GERENTE ACESSAR TODAS AS TABELAS E CONCEDER PERMISSÕES PARA OUTROS USUÁRIOS
GRANT SELECT, INSERT ON cliente, reserva, hospedagem, quarto, tipo_quarto, atendimento, servico, listaClientes TO gerente WITH GRANT OPTION;

--CONCEDENDO PERMISSÕES PARA O ROLE GERENTE ACESSAR A FUNÇÃO adicionaHospedagem
GRANT EXECUTE ON FUNCTION adicionaHospedagem(numeric, int) TO gerente;

--CONCEDENDO PERMISSÕES PARA O ROLE GERENTE ACESSAR A FUNÇÃO adicionaReserva
GRANT EXECUTE ON FUNCTION adicionaReserva(numeric, int, int, date) TO gerente;

--CONCEDENDO PERMISSÕES PARA O ROLE GERENTE ACESSAR A FUNÇÃO adicionaPedido
GRANT EXECUTE ON FUNCTION realizaPedido(int, int) TO gerente;

--CONCEDENDO PERMISSÃO PARA O ROLE GERENTE ACESSAR A VIEW listaClientes
GRANT SELECT ON listaClientes TO gerente;

--CONCEDENDO PERMISSÃO PARA ACESSAR O sequence tipo_quarto_id_tipo_seq
GRANT ALL ON sequence tipo_quarto_id_tipo_seq TO gerente;




/* ##########  CONCEDENDO PERMISSÕES DO ATENDENTE  ##########*/

--CONCEDENDO PERMISÃO PARA O ATENDENTE ACESSAR A FUNÇÃO adicionaHospedagem
GRANT EXECUTE ON FUNCTION adicionaHospedagem(numeric, int) TO atendente;

--CONCEDENDO PERMISSÃO PARA O ATENDENTE ACESSAR A FUNÇÃO adicionaReserva
GRANT EXECUTE ON FUNCTION adicionaReserva(numeric, int, int, date) TO atendente;

--CONCEDENDO PERMISSÃO PARA O RULE ATENDENTE ACESSAR A FUNCTION realizaPedido
GRANT EXECUTE ON FUNCTION realizaPedido(int, int) TO atendente;



/* ##########  CONCEDENDO PERMISSÕES DO ESTAGIÁRIO  ##########*/

--CONCEDENDO PERMISSÃO PARA O ROLE ESTAGIÁRIO ACESSAR A VIEW listaClientes
GRANT SELECT ON listaClientes TO estagiario;



/* ##########  CRIANDO USUÁRIOS PARA LOGAR NO SISTEMA  ##########*/
--CRIA O USUÁRIO TONY COM SENHA '111' NO ROLE 'gerente'
CREATE ROLE tony LOGIN PASSWORD '111' IN ROLE gerente;

--CRIA O USUÁRIO MARIA COM SENHA '222' NO ROLE 'atendente'
CREATE ROLE maria LOGIN PASSWORD '222' IN ROLE 	atendente;

--CRIA O USUÁRIO vitoria COM SENHA '333' NO ROLE 'estagiario'
CREATE ROLE vitoria LOGIN PASSWORD '333' IN ROLE estagiario;






