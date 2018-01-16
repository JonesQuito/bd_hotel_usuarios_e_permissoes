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
      RAISE EXCEPTION 'Clinte não cosnta no cadastro';
    end if;
  END;
  $$
  LANGUAGE plpgsql SECURITY DEFINER;







