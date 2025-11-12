DROP DATABASE IF EXISTS sistema_inscricoes_eventos;
CREATE DATABASE sistema_inscricoes_eventos;
USE sistema_inscricoes_eventos;

CREATE TABLE Pessoas (
  id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf CHAR(11) NOT NULL,
  senha_normal VARCHAR(255) NOT NULL,
  senha_criptografada VARCHAR(255) NOT NULL,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Alunos (
  id_aluno INT PRIMARY KEY,
  email VARCHAR(150),
  telefone VARCHAR(20),
  matricula VARCHAR(30),
  FOREIGN KEY (id_aluno) REFERENCES Pessoas(id_pessoa)
);

CREATE TABLE Servidores (
  id_servidor INT PRIMARY KEY,
  email VARCHAR(150),
  telefone VARCHAR(20),
  tipo_servidor VARCHAR(30),
  siape VARCHAR(30),
  FOREIGN KEY (id_servidor) REFERENCES Pessoas(id_pessoa)
);

CREATE TABLE Externos (
  id_externo INT PRIMARY KEY,
  email VARCHAR(150),
  telefone VARCHAR(20),
  empresa VARCHAR(150),
  FOREIGN KEY (id_externo) REFERENCES Pessoas(id_pessoa)
);

CREATE TABLE Administradores (
  id_admin INT PRIMARY KEY,
  email VARCHAR(150),
  telefone VARCHAR(20),
  nivel_acesso INT,
  FOREIGN KEY (id_admin) REFERENCES Pessoas(id_pessoa)
);

CREATE TABLE Eventos (
  id_evento INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  data_evento DATE,
  local VARCHAR(150),
  vagas INT
);

CREATE TABLE Inscricoes (
  id_inscricao INT AUTO_INCREMENT PRIMARY KEY,
  id_pessoa INT,
  id_evento INT,
  data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(20),
  FOREIGN KEY (id_pessoa) REFERENCES Pessoas(id_pessoa),
  FOREIGN KEY (id_evento) REFERENCES Eventos(id_evento)
);

INSERT INTO Pessoas (id_pessoa, nome, cpf, senha_normal, senha_criptografada)
VALUES
  (1, 'Ana Souza', '12345678901', 'senhaAna', 'senhaAna'),
  (2, 'Bruno Lima', '23456789012', 'senhaBruno', 'senhaBruno'),
  (3, 'Carla Dias', '34567890123', 'senhaCarla', 'senhaCarla'),
  (4, 'Daniel Costa', '45678901234', 'senhaDaniel', 'senhaDaniel'),
  (5, 'Eduardo Alves', '56789012345', 'senhaEdu', 'senhaEdu');

INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES
  (1, 'ana.souza@alunos.edu', '(11)90000-0001', '2025001'),
  (5, 'eduardo.alves@alunos.edu', '(11)90000-0005', '2025002');

INSERT INTO Servidores (id_servidor, email, telefone, tipo_servidor, siape)
VALUES
  (2, 'bruno.lima@if.edu', '(11)90000-0002', 'Tecnico', 'SIAPE1234');

INSERT INTO Externos (id_externo, email, telefone, empresa)
VALUES
  (3, 'carla.dias@empresa.com', '(11)90000-0003', 'Tech Eventos');

INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso)
VALUES
  (4, 'daniel.costa@if.edu', '(11)90000-0004', 5);

INSERT INTO Eventos (id_evento, nome, data_evento, local, vagas)
VALUES
  (1, 'Semana de Tecnologia', '2025-03-15', 'Auditorio Central', 150),
  (2, 'Workshop de Inovacao', '2025-04-20', 'Laboratorio 3', 80);

INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES
  (1, 1, 'Confirmado'),
  (2, 1, 'Aguardando'),
  (3, 2, 'Confirmado');

SELECT id_pessoa, nome, cpf
FROM Pessoas;

SELECT Eventos.nome AS evento, Pessoas.nome AS participante, Inscricoes.status
FROM Inscricoes
JOIN Eventos ON Eventos.id_evento = Inscricoes.id_evento
JOIN Pessoas ON Pessoas.id_pessoa = Inscricoes.id_pessoa
ORDER BY Eventos.nome;

SELECT Eventos.nome, COUNT(Inscricoes.id_inscricao) AS total_inscritos
FROM Eventos
LEFT JOIN Inscricoes ON Inscricoes.id_evento = Eventos.id_evento
GROUP BY Eventos.id_evento, Eventos.nome;

SELECT nome, cpf
FROM Pessoas
WHERE nome LIKE 'A%';

SELECT Pessoas.nome, Inscricoes.status
FROM Pessoas
JOIN Inscricoes ON Inscricoes.id_pessoa = Pessoas.id_pessoa
WHERE Inscricoes.status = 'Confirmado';

UPDATE Alunos
SET email = 'ana.souza.atualizado@alunos.edu'
WHERE id_aluno = 1;

UPDATE Inscricoes
SET status = 'Confirmado'
WHERE id_inscricao = 2;

UPDATE Servidores
SET tipo_servidor = 'Professor'
WHERE id_servidor = 2;

DELETE FROM Inscricoes
WHERE id_inscricao = 2;

DELETE FROM Eventos
WHERE id_evento = 1;

DELETE FROM Pessoas
WHERE id_pessoa = 3;
