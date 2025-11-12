-- ======================================================================
-- Script: create_and_test.sql
-- Objetivo: Modelagem e demonstração de operações CRUD para o sistema
--           de inscrições em eventos (MySQL 8.0+).
--           Inclui definição de esquema, dados de teste, consultas,
--           atualizações, deleções e cenários de validação.
-- ======================================================================

-- ----------------------------------------------------------------------
-- 1. Preparação do banco de dados
-- ----------------------------------------------------------------------

DROP DATABASE IF EXISTS sistema_inscricoes_eventos;
CREATE DATABASE IF NOT EXISTS sistema_inscricoes_eventos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_inscricoes_eventos;

-- ----------------------------------------------------------------------
-- 2. Definição das tabelas (DDL)
-- ----------------------------------------------------------------------

-- Tabela supertipo: Pessoas
CREATE TABLE Pessoas (
  id_pessoa            INT AUTO_INCREMENT PRIMARY KEY,
  nome                 VARCHAR(100)        NOT NULL,
  cpf                  CHAR(11)            NOT NULL,
  senha_normal         VARCHAR(255)        NOT NULL,
  senha_criptografada  VARCHAR(255)        NOT NULL,
  data_cadastro        TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_pessoas_cpf UNIQUE (cpf),
  CONSTRAINT chk_pessoas_cpf_length CHECK (CHAR_LENGTH(cpf) = 11),
  INDEX idx_pessoas_cpf (cpf),
  INDEX idx_pessoas_nome (nome)
) ENGINE = InnoDB;

-- Subtipo: Alunos
CREATE TABLE Alunos (
  id_aluno INT PRIMARY KEY,
  email    VARCHAR(150) NOT NULL,
  telefone VARCHAR(20),
  matricula VARCHAR(30) NOT NULL,
  CONSTRAINT uq_alunos_email UNIQUE (email),
  CONSTRAINT uq_alunos_matricula UNIQUE (matricula),
  CONSTRAINT fk_alunos_pessoas FOREIGN KEY (id_aluno)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- Subtipo: Servidores
CREATE TABLE Servidores (
  id_servidor   INT PRIMARY KEY,
  email         VARCHAR(150) NOT NULL,
  telefone      VARCHAR(20),
  tipo_servidor ENUM('Professor', 'Técnico', 'Tercerizado', 'Estagiário') NOT NULL,
  siape         VARCHAR(30),
  CONSTRAINT uq_servidores_email UNIQUE (email),
  CONSTRAINT uq_servidores_siape UNIQUE (siape),
  CONSTRAINT fk_servidores_pessoas FOREIGN KEY (id_servidor)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- Subtipo: Externos
CREATE TABLE Externos (
  id_externo INT PRIMARY KEY,
  email      VARCHAR(150) NOT NULL,
  telefone   VARCHAR(20),
  empresa    VARCHAR(150) NOT NULL,
  CONSTRAINT uq_externos_email UNIQUE (email),
  CONSTRAINT fk_externos_pessoas FOREIGN KEY (id_externo)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

-- Subtipo: Administradores
CREATE TABLE Administradores (
  id_admin      INT PRIMARY KEY,
  email         VARCHAR(150) NOT NULL,
  telefone      VARCHAR(20),
  nivel_acesso  TINYINT NOT NULL,
  CONSTRAINT uq_admin_email UNIQUE (email),
  CONSTRAINT fk_admin_pessoas FOREIGN KEY (id_admin)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE,
  CONSTRAINT chk_admin_nivel CHECK (nivel_acesso BETWEEN 1 AND 5)
) ENGINE = InnoDB;

-- Tabela de eventos
CREATE TABLE Eventos (
  id_evento    INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(150) NOT NULL,
  data_evento  DATE         NOT NULL,
  local        VARCHAR(150) NOT NULL,
  vagas        INT NOT NULL DEFAULT 100,
  CONSTRAINT chk_eventos_vagas CHECK (vagas >= 0),
  INDEX idx_eventos_data (data_evento),
  INDEX idx_eventos_nome (nome)
) ENGINE = InnoDB;

-- Tabela de inscrições (relacionamento N:M entre Pessoas e Eventos)
CREATE TABLE Inscricoes (
  id_inscricao INT AUTO_INCREMENT PRIMARY KEY,
  id_pessoa    INT NOT NULL,
  id_evento    INT NOT NULL,
  data_inscricao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Aguardando', 'Confirmado', 'Cancelado') NOT NULL DEFAULT 'Aguardando',
  CONSTRAINT uq_inscricoes_pessoa_evento UNIQUE (id_pessoa, id_evento),
  CONSTRAINT fk_inscricoes_pessoa FOREIGN KEY (id_pessoa)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE,
  CONSTRAINT fk_inscricoes_evento FOREIGN KEY (id_evento)
    REFERENCES Eventos (id_evento)
    ON DELETE CASCADE,
  INDEX idx_inscricoes_status (status)
) ENGINE = InnoDB;

-- ----------------------------------------------------------------------
-- 3. Dados de teste (DML - INSERT)
-- ----------------------------------------------------------------------

START TRANSACTION;

-- Pessoa 1: Aluno
INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Ana Souza', '12345678901', 'senhaAna', SHA2('senhaAna', 256));
SET @id_aluno1 = LAST_INSERT_ID();
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (@id_aluno1, 'ana.souza@alunos.edu', '(11)90000-0001', '2025001');

-- Pessoa 2: Servidor
INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Bruno Lima', '23456789012', 'senhaBruno', SHA2('senhaBruno', 256));
SET @id_servidor1 = LAST_INSERT_ID();
INSERT INTO Servidores (id_servidor, email, telefone, tipo_servidor, siape)
VALUES (@id_servidor1, 'bruno.lima@if.edu', '(11)90000-0002', 'Técnico', 'SIAPE1234');

-- Pessoa 3: Externo
INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Carla Dias', '34567890123', 'senhaCarla', SHA2('senhaCarla', 256));
SET @id_externo1 = LAST_INSERT_ID();
INSERT INTO Externos (id_externo, email, telefone, empresa)
VALUES (@id_externo1, 'carla.dias@empresa.com', '(11)90000-0003', 'Tech Eventos');

-- Pessoa 4: Administrador
INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Daniel Costa', '45678901234', 'senhaDaniel', SHA2('senhaDaniel', 256));
SET @id_admin1 = LAST_INSERT_ID();
INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso)
VALUES (@id_admin1, 'daniel.costa@if.edu', '(11)90000-0004', 5);

-- Pessoa 5: Aluno (segundo exemplo)
INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Eduardo Alves', '56789012345', 'senhaEdu', SHA2('senhaEdu', 256));
SET @id_aluno2 = LAST_INSERT_ID();
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (@id_aluno2, 'eduardo.alves@alunos.edu', '(11)90000-0005', '2025002');

-- Eventos de teste
INSERT INTO Eventos (nome, data_evento, local, vagas)
VALUES 
  ('Semana de Tecnologia', '2025-03-15', 'Auditório Central', 150),
  ('Workshop de Inovação', '2025-04-20', 'Laboratório 3', 80);

SET @id_evento1 = (
  SELECT id_evento FROM Eventos WHERE nome = 'Semana de Tecnologia' LIMIT 1
);
SET @id_evento2 = (
  SELECT id_evento FROM Eventos WHERE nome = 'Workshop de Inovação' LIMIT 1
);

-- Inscrições (3 exemplos)
INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES
  (@id_aluno1, @id_evento1, 'Confirmado'),
  (@id_servidor1, @id_evento1, 'Aguardando'),
  (@id_externo1, @id_evento2, 'Confirmado');

COMMIT;

-- ----------------------------------------------------------------------
-- 4. Consultas (SELECT - READ)
-- ----------------------------------------------------------------------

-- Q1: Listagem básica de pessoas
SELECT id_pessoa, nome, cpf, data_cadastro
FROM Pessoas
ORDER BY data_cadastro;

-- Q2: Listar inscritos por evento com detalhes (JOIN múltiplo)
SELECT e.nome AS evento,
       p.nome AS participante,
       COALESCE(a.matricula, s.siape, ex.empresa, 'Administrador') AS referencia_tipo,
       i.status,
       i.data_inscricao
FROM Inscricoes i
JOIN Eventos e       ON e.id_evento = i.id_evento
JOIN Pessoas p       ON p.id_pessoa = i.id_pessoa
LEFT JOIN Alunos a         ON a.id_aluno = p.id_pessoa
LEFT JOIN Servidores s     ON s.id_servidor = p.id_pessoa
LEFT JOIN Externos ex      ON ex.id_externo = p.id_pessoa
LEFT JOIN Administradores ad ON ad.id_admin = p.id_pessoa
ORDER BY e.nome, p.nome;

-- Q3: Vagas restantes em cada evento (subquery + agregação)
SELECT e.id_evento,
       e.nome,
       e.vagas,
       e.vagas - (
         SELECT COUNT(*)
         FROM Inscricoes i
         WHERE i.id_evento = e.id_evento
           AND i.status <> 'Cancelado'
       ) AS vagas_restantes
FROM Eventos e;

-- Q4: Contagem de usuários por tipo (agregação com UNION ALL)
SELECT 'Alunos' AS tipo_usuario, COUNT(*) AS total FROM Alunos
UNION ALL
SELECT 'Servidores', COUNT(*) FROM Servidores
UNION ALL
SELECT 'Externos', COUNT(*) FROM Externos
UNION ALL
SELECT 'Administradores', COUNT(*) FROM Administradores;

-- Q5: Buscar inscrições confirmadas de pessoas de fora da instituição (subquery)
SELECT p.nome, ex.empresa, e.nome AS evento
FROM Pessoas p
JOIN Externos ex   ON ex.id_externo = p.id_pessoa
WHERE EXISTS (
  SELECT 1
  FROM Inscricoes i
  WHERE i.id_pessoa = p.id_pessoa
    AND i.status = 'Confirmado'
);

-- ----------------------------------------------------------------------
-- 5. Atualizações (UPDATE)
-- ----------------------------------------------------------------------

-- U1: Atualizar email de um aluno (edição de perfil)
UPDATE Alunos
SET email = 'ana.souza.atualizado@alunos.edu'
WHERE id_aluno = @id_aluno1;

-- U2: Atualizar status de inscrição
UPDATE Inscricoes
SET status = 'Confirmado'
WHERE id_inscricao = 2;

-- U3: Mudar tipo de servidor
UPDATE Servidores
SET tipo_servidor = 'Professor'
WHERE id_servidor = @id_servidor1;

-- ----------------------------------------------------------------------
-- 6. Remoções (DELETE) com uso de transações
-- ----------------------------------------------------------------------

-- D1: Remover uma inscrição específica
START TRANSACTION;
DELETE FROM Inscricoes
WHERE id_inscricao = 2;
ROLLBACK; -- Reverte para manter dados de teste

-- D2: Remover evento (demonstra cascade para inscrições)
START TRANSACTION;
DELETE FROM Eventos
WHERE id_evento = @id_evento1;
ROLLBACK;

-- D3: Remover usuário completo (cascade em subtipo e inscrições)
START TRANSACTION;
DELETE FROM Pessoas
WHERE id_pessoa = @id_externo1;
ROLLBACK;

-- ----------------------------------------------------------------------
-- 7. Testes de validação (executar manualmente conforme relatório)
--    Remova os comentários para executar individualmente.
-- ----------------------------------------------------------------------

-- Teste T1: Violação de UNIQUE (CPF duplicado)
-- INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
-- VALUES ('Teste CPF Duplicado', '12345678901', 'senha', SHA2('senha', 256));

-- Teste T2: Violação de CHECK (nível de acesso inválido)
-- INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso)
-- VALUES (@id_admin1, 'admin.invalido@if.edu', '(11)90000-0009', 10);

-- Teste T3: Violação de FK (inscrição sem pessoa existente)
-- INSERT INTO Inscricoes (id_pessoa, id_evento, status)
-- VALUES (9999, @id_evento1, 'Confirmado');

-- Teste T4: Tentativa de alterar PK diretamente (não permitido)
-- UPDATE Pessoas SET id_pessoa = 100 WHERE id_pessoa = @id_aluno1;

-- Teste T5: Exclusão de pessoa inexistente (0 linhas afetadas)
-- DELETE FROM Pessoas WHERE id_pessoa = 9999;

-- ----------------------------------------------------------------------
-- Fim do script
-- ----------------------------------------------------------------------
