DROP DATABASE IF EXISTS sistema_inscricoes_eventos;
CREATE DATABASE IF NOT EXISTS sistema_inscricoes_eventos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE sistema_inscricoes_eventos;

CREATE TABLE Pessoas (
  id_pessoa INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cpf CHAR(11) NOT NULL,
  senha_normal VARCHAR(255) NOT NULL,
  senha_criptografada VARCHAR(255) NOT NULL,
  data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_pessoas_cpf UNIQUE (cpf),
  CONSTRAINT chk_pessoas_cpf CHECK (CHAR_LENGTH(cpf) = 11),
  INDEX idx_pessoas_cpf (cpf),
  INDEX idx_pessoas_nome (nome)
) ENGINE = InnoDB;

CREATE TABLE Alunos (
  id_aluno INT PRIMARY KEY,
  email VARCHAR(150) NOT NULL,
  telefone VARCHAR(20),
  matricula VARCHAR(30) NOT NULL,
  CONSTRAINT uq_alunos_email UNIQUE (email),
  CONSTRAINT uq_alunos_matricula UNIQUE (matricula),
  CONSTRAINT fk_alunos_pessoas FOREIGN KEY (id_aluno)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Servidores (
  id_servidor INT PRIMARY KEY,
  email VARCHAR(150) NOT NULL,
  telefone VARCHAR(20),
  tipo_servidor ENUM('Professor','Tecnico','Tercerizado','Estagiario') NOT NULL,
  siape VARCHAR(30),
  CONSTRAINT uq_servidores_email UNIQUE (email),
  CONSTRAINT uq_servidores_siape UNIQUE (siape),
  CONSTRAINT fk_servidores_pessoas FOREIGN KEY (id_servidor)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Externos (
  id_externo INT PRIMARY KEY,
  email VARCHAR(150) NOT NULL,
  telefone VARCHAR(20),
  empresa VARCHAR(150) NOT NULL,
  CONSTRAINT uq_externos_email UNIQUE (email),
  CONSTRAINT fk_externos_pessoas FOREIGN KEY (id_externo)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE Administradores (
  id_admin INT PRIMARY KEY,
  email VARCHAR(150) NOT NULL,
  telefone VARCHAR(20),
  nivel_acesso TINYINT NOT NULL,
  CONSTRAINT uq_admin_email UNIQUE (email),
  CONSTRAINT fk_admin_pessoas FOREIGN KEY (id_admin)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE,
  CONSTRAINT chk_admin_nivel CHECK (nivel_acesso BETWEEN 1 AND 5)
) ENGINE = InnoDB;

CREATE TABLE Eventos (
  id_evento INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(150) NOT NULL,
  data_evento DATE NOT NULL,
  local VARCHAR(150) NOT NULL,
  vagas INT NOT NULL DEFAULT 100,
  CONSTRAINT chk_eventos_vagas CHECK (vagas >= 0),
  INDEX idx_eventos_data (data_evento),
  INDEX idx_eventos_nome (nome)
) ENGINE = InnoDB;

CREATE TABLE Inscricoes (
  id_inscricao INT AUTO_INCREMENT PRIMARY KEY,
  id_pessoa INT NOT NULL,
  id_evento INT NOT NULL,
  data_inscricao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('Aguardando','Confirmado','Cancelado') NOT NULL DEFAULT 'Aguardando',
  CONSTRAINT uq_inscricoes_pessoa_evento UNIQUE (id_pessoa, id_evento),
  CONSTRAINT fk_inscricoes_pessoa FOREIGN KEY (id_pessoa)
    REFERENCES Pessoas (id_pessoa)
    ON DELETE CASCADE,
  CONSTRAINT fk_inscricoes_evento FOREIGN KEY (id_evento)
    REFERENCES Eventos (id_evento)
    ON DELETE CASCADE,
  INDEX idx_inscricoes_status (status)
) ENGINE = InnoDB;

START TRANSACTION;

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Ana Souza', '12345678901', 'senhaAna', SHA2('senhaAna', 256));
SET @id_aluno1 = LAST_INSERT_ID();
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (@id_aluno1, 'ana.souza@alunos.edu', '(11)90000-0001', '2025001');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Bruno Lima', '23456789012', 'senhaBruno', SHA2('senhaBruno', 256));
SET @id_servidor1 = LAST_INSERT_ID();
INSERT INTO Servidores (id_servidor, email, telefone, tipo_servidor, siape)
VALUES (@id_servidor1, 'bruno.lima@if.edu', '(11)90000-0002', 'Tecnico', 'SIAPE1234');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Carla Dias', '34567890123', 'senhaCarla', SHA2('senhaCarla', 256));
SET @id_externo1 = LAST_INSERT_ID();
INSERT INTO Externos (id_externo, email, telefone, empresa)
VALUES (@id_externo1, 'carla.dias@empresa.com', '(11)90000-0003', 'Tech Eventos');

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Daniel Costa', '45678901234', 'senhaDaniel', SHA2('senhaDaniel', 256));
SET @id_admin1 = LAST_INSERT_ID();
INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso)
VALUES (@id_admin1, 'daniel.costa@if.edu', '(11)90000-0004', 5);

INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada)
VALUES ('Eduardo Alves', '56789012345', 'senhaEdu', SHA2('senhaEdu', 256));
SET @id_aluno2 = LAST_INSERT_ID();
INSERT INTO Alunos (id_aluno, email, telefone, matricula)
VALUES (@id_aluno2, 'eduardo.alves@alunos.edu', '(11)90000-0005', '2025002');

INSERT INTO Eventos (nome, data_evento, local, vagas)
VALUES ('Semana de Tecnologia', '2025-03-15', 'Auditorio Central', 150);
SET @id_evento1 = LAST_INSERT_ID();

INSERT INTO Eventos (nome, data_evento, local, vagas)
VALUES ('Workshop de Inovacao', '2025-04-20', 'Laboratorio 3', 80);
SET @id_evento2 = LAST_INSERT_ID();

INSERT INTO Inscricoes (id_pessoa, id_evento, status)
VALUES
  (@id_aluno1, @id_evento1, 'Confirmado'),
  (@id_servidor1, @id_evento1, 'Aguardando'),
  (@id_externo1, @id_evento2, 'Confirmado');

COMMIT;

SELECT id_pessoa, nome, cpf, data_cadastro
FROM Pessoas
ORDER BY data_cadastro;

SELECT e.nome AS evento,
       p.nome AS participante,
       COALESCE(a.matricula, s.siape, ex.empresa, 'Administrador') AS referencia_tipo,
       i.status,
       i.data_inscricao
FROM Inscricoes i
JOIN Eventos e ON e.id_evento = i.id_evento
JOIN Pessoas p ON p.id_pessoa = i.id_pessoa
LEFT JOIN Alunos a ON a.id_aluno = p.id_pessoa
LEFT JOIN Servidores s ON s.id_servidor = p.id_pessoa
LEFT JOIN Externos ex ON ex.id_externo = p.id_pessoa
LEFT JOIN Administradores ad ON ad.id_admin = p.id_pessoa
ORDER BY e.nome, p.nome;

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

SELECT 'Alunos' AS tipo_usuario, COUNT(*) AS total FROM Alunos
UNION ALL
SELECT 'Servidores', COUNT(*) FROM Servidores
UNION ALL
SELECT 'Externos', COUNT(*) FROM Externos
UNION ALL
SELECT 'Administradores', COUNT(*) FROM Administradores;

SELECT p.nome, ex.empresa, e.nome AS evento
FROM Pessoas p
JOIN Externos ex ON ex.id_externo = p.id_pessoa
WHERE EXISTS (
  SELECT 1
  FROM Inscricoes i
  WHERE i.id_pessoa = p.id_pessoa
    AND i.status = 'Confirmado'
);

UPDATE Alunos
SET email = 'ana.souza.atualizado@alunos.edu'
WHERE id_aluno = @id_aluno1;

UPDATE Inscricoes
SET status = 'Confirmado'
WHERE id_inscricao = 2;

UPDATE Servidores
SET tipo_servidor = 'Professor'
WHERE id_servidor = @id_servidor1;

START TRANSACTION;
DELETE FROM Inscricoes
WHERE id_inscricao = 2;
ROLLBACK;

START TRANSACTION;
DELETE FROM Eventos
WHERE id_evento = @id_evento1;
ROLLBACK;

START TRANSACTION;
DELETE FROM Pessoas
WHERE id_pessoa = @id_externo1;
ROLLBACK;

-- Testes de validação (descomente individualmente para executar)
-- INSERT INTO Pessoas (nome, cpf, senha_normal, senha_criptografada) VALUES ('CPF Duplicado', '12345678901', 'senha', SHA2('senha', 256));
-- INSERT INTO Administradores (id_admin, email, telefone, nivel_acesso) VALUES (@id_admin1, 'admin.invalido@if.edu', '(11)90000-0090', 10);
-- INSERT INTO Inscricoes (id_pessoa, id_evento, status) VALUES (9999, @id_evento1, 'Confirmado');
-- UPDATE Pessoas SET id_pessoa = 999 WHERE id_pessoa = @id_aluno1;
-- DELETE FROM Pessoas WHERE id_pessoa = 9999;
