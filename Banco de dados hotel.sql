select usename from pg_user; --Lista os usuários de banco de dados

select current_user -- Exibe o usuário atual

select groname from pg_group; -- Lista os grupos de usuários(papeis) de banco de dados

CREATE DATABASE hotel;

-- CRIA A TABELA DE CLIENTES
CREATE TABLE cliente
(
	rg numeric not null,
	nome varchar(40) not null,
	sexo char(1) not null,
	telefone numeric(10,0),
	primary key(rg)
)without oids;