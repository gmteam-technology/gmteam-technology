DROP TABLE IF EXISTS Inscricoes;
DROP TABLE IF EXISTS Administradores;
DROP TABLE IF EXISTS Externos;
DROP TABLE IF EXISTS Servidores;
DROP TABLE IF EXISTS Alunos;
DROP TABLE IF EXISTS Eventos;
DROP TABLE IF EXISTS Pessoas;

CREATE TABLE Pessoas (
  id_pessoa INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  cpf TEXT NOT NULL UNIQUE,
  senha_normal TEXT NOT NULL,
  senha_criptografada TEXT NOT NULL,
  data_cadastro TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (LENGTH(cpf) = 11)
);

CREATE INDEX idx_pessoas_cpf ON Pessoas(cpf);
CREATE INDEX idx_pessoas_nome ON Pessoas(nome);

CREATE TABLE Alunos (
  id_aluno INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  telefone TEXT,
  matricula TEXT NOT NULL UNIQUE,
  FOREIGN KEY (id_aluno) REFERENCES Pessoas(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE Servidores (
  id_servidor INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  telefone TEXT,
  tipo_servidor TEXT NOT NULL,
  siape TEXT UNIQUE,
  CHECK (tipo_servidor IN ('Professor','Técnico','Tercerizado','Estagiário')),
  FOREIGN KEY (id_servidor) REFERENCES Pessoas(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE Externos (
  id_externo INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  telefone TEXT,
  empresa TEXT NOT NULL,
  FOREIGN KEY (id_externo) REFERENCES Pessoas(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE Administradores (
  id_admin INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  telefone TEXT,
  nivel_acesso INTEGER NOT NULL,
  CHECK (nivel_acesso BETWEEN 1 AND 5),
  FOREIGN KEY (id_admin) REFERENCES Pessoas(id_pessoa) ON DELETE CASCADE
);

CREATE TABLE Eventos (
  id_evento INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL,
  data_evento TEXT NOT NULL,
  local TEXT NOT NULL,
  vagas INTEGER NOT NULL DEFAULT 100,
  CHECK (vagas >= 0)
);

CREATE INDEX idx_eventos_data ON Eventos(data_evento);
CREATE INDEX idx_eventos_nome ON Eventos(nome);

CREATE TABLE Inscricoes (
  id_inscricao INTEGER PRIMARY KEY AUTOINCREMENT,
  id_pessoa INTEGER NOT NULL,
  id_evento INTEGER NOT NULL,
  data_inscricao TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status TEXT NOT NULL DEFAULT 'Aguardando',
  CHECK (status IN ('Aguardando','Confirmado','Cancelado')),
  UNIQUE (id_pessoa, id_evento),
  FOREIGN KEY (id_pessoa) REFERENCES Pessoas(id_pessoa) ON DELETE CASCADE,
  FOREIGN KEY (id_evento) REFERENCES Eventos(id_evento) ON DELETE CASCADE
);

CREATE INDEX idx_inscricoes_status ON Inscricoes(status);

BEGIN TRANSACTION;

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Ana Souza', '12345678901', 'senhaAna', '358d65b949cf9f5dbe7a5c9e065de4627375439203dd1511f7b24cb59d484bb4');
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (last_insert_rowid(), 'ana.souza@alunos.edu', '11900000001', '2025001');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Bruno Lima', '23456789012', 'senhaBruno', 'bd7ec1bf19c74bd895b5facd6fc0f2bdffaa4b8d173c985ea094bc42f8c624a1');
INSERT INTO Servidores (id_servidor, email, telefone, tipo_servidor, siape)
VALUES (last_insert_rowid(), 'bruno.lima@if.edu', '11900000002', 'Tecnico', 'SIAPE1234');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Carla Dias', '34567890123', 'senhaCarla', 'c17fa12130ff247b490e18ae405e103bf543dcf371cee2b51f7052ff29cb6fd9');
INSERT INTO Externos (id_externo, email, telefone, empresa)
VALUES (last_insert_rowid(), 'carla.dias@empresa.com', '11900000003', 'Tech Eventos');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Daniel Costa', '45678901234', 'senhaDaniel', '09eb0a911ae0a2a715434d44203a3df64ecec5bdd71648ee876c092b5087427c');
INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso)
VALUES (last_insert_rowid(), 'daniel.costa@if.edu', '11900000004', 5);

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Eduardo Alves', '56789012345', 'senhaEdu', '4debcc60d4b31cb7dad0084dfca2c2fe95a6c47202f3dc5a911dae9c17f425c8');
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (last_insert_rowid(), 'eduardo.alves@alunos.edu', '11900000005', '2025002');

INSERT INTO Eventos (nome, data_evento, local, vagas)
VALUES ('Semana de Tecnologia', '2025-03-15', 'Auditorio Central', 150);

INSERT INTO Eventos (nome, data_evento, local, vagas)
VALUES ('Workshop de Inovacao', '2025-04-20', 'Laboratorio 3', 80);

INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES (
  (SELECT id_pessoa FROM Pessoas WHERE cpf = '12345678901'),
  (SELECT id_evento FROM Eventos WHERE nome = 'Semana de Tecnologia'),
  'Confirmado'
);

INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES (
  (SELECT id_pessoa FROM Pessoas WHERE cpf = '23456789012'),
  (SELECT id_evento FROM Eventos WHERE nome = 'Semana de Tecnologia'),
  'Aguardando'
);

INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES (
  (SELECT id_pessoa FROM Pessoas WHERE cpf = '34567890123'),
  (SELECT id_evento FROM Eventos WHERE nome = 'Workshop de Inovação'),
  'Confirmado'
);

COMMIT;

SELECT id_pessoa, nome, cpf, data_cadastro
FROM Pessoas
ORDER BY data_cadastro;

SELECT Eventos.nome AS evento,
       Pessoas.nome AS participante,
       COALESCE(Alunos.matricula, Servidores.siape, Externos.empresa, CASE WHEN Administradores.id_admin IS NOT NULL THEN 'Administrador' END) AS referencia_tipo,
       Inscricoes.status,
       Inscricoes.data_inscricao
FROM Inscricoes
JOIN Eventos ON Eventos.id_evento = Inscricoes.id_evento
JOIN Pessoas ON Pessoas.id_pessoa = Inscricoes.id_pessoa
LEFT JOIN Alunos ON Alunos.id_aluno = Pessoas.id_pessoa
LEFT JOIN Servidores ON Servidores.id_servidor = Pessoas.id_pessoa
LEFT JOIN Externos ON Externos.id_externo = Pessoas.id_pessoa
LEFT JOIN Administradores ON Administradores.id_admin = Pessoas.id_pessoa
ORDER BY Eventos.nome, Pessoas.nome;

SELECT Eventos.id_evento,
       Eventos.nome,
       Eventos.vagas,
       Eventos.vagas - (
         SELECT COUNT(*)
         FROM Inscricoes
         WHERE Inscricoes.id_evento = Eventos.id_evento
           AND Inscricoes.status <> 'Cancelado'
       ) AS vagas_restantes
FROM Eventos;

SELECT resumo.tipo_usuario, resumo.total
FROM (
  SELECT 'Alunos' AS tipo_usuario, COUNT(*) AS total FROM Alunos
  UNION ALL
  SELECT 'Servidores', COUNT(*) FROM Servidores
  UNION ALL
  SELECT 'Externos', COUNT(*) FROM Externos
  UNION ALL
  SELECT 'Administradores', COUNT(*) FROM Administradores
) AS resumo;

SELECT Pessoas.nome, Externos.empresa, Eventos.nome AS evento
FROM Pessoas
JOIN Externos ON Externos.id_externo = Pessoas.id_pessoa
JOIN Inscricoes ON Inscricoes.id_pessoa = Pessoas.id_pessoa
JOIN Eventos ON Eventos.id_evento = Inscricoes.id_evento
WHERE Inscricoes.status = 'Confirmado';

UPDATE Alunos
SET email = 'ana.souza.atualizado@alunos.edu'
WHERE id_aluno = (SELECT id_pessoa FROM Pessoas WHERE cpf = '12345678901');

UPDATE Inscricoes
SET status = 'Confirmado'
WHERE id_pessoa = (SELECT id_pessoa FROM Pessoas WHERE cpf = '23456789012')
  AND id_evento = (SELECT id_evento FROM Eventos WHERE nome = 'Semana de Tecnologia');

UPDATE Servidores
SET tipo_servidor = 'Professor'
WHERE id_servidor = (SELECT id_pessoa FROM Pessoas WHERE cpf = '23456789012');

BEGIN TRANSACTION;
DELETE FROM Inscricoes
WHERE id_pessoa = (SELECT id_pessoa FROM Pessoas WHERE cpf = '23456789012')
  AND id_evento = (SELECT id_evento FROM Eventos WHERE nome = 'Semana de Tecnologia');
ROLLBACK;

BEGIN TRANSACTION;
DELETE FROM Eventos
WHERE nome = 'Semana de Tecnologia';
ROLLBACK;

BEGIN TRANSACTION;
DELETE FROM Pessoas
WHERE cpf = '34567890123';
ROLLBACK;
