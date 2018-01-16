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
	foreign key(id_tipo) references tipo_quarto (id_tipo),
)WITHOUT OIDS;






