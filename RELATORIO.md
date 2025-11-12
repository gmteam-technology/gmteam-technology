# Modelagem e Implementação do Banco de Dados para o Sistema de Inscrição em Eventos

## 1. Introdução

Este relatório apresenta a modelagem e a implementação do banco de dados relacional `sistema_inscricoes_eventos`, desenvolvido em MySQL 8.0 como entrega da disciplina de Banco de Dados. O objetivo principal é sustentar cadastros diferenciados de usuários, gerenciamento de eventos e inscrições, garantindo integridade referencial, normalização dos dados e desempenho adequado por meio de chaves primárias, estrangeiras, constraints e índices.

O script completo encontra-se em `create_and_test.sql` e pode ser executado diretamente no servidor MySQL:

```
mysql -u <USUARIO> -p < create_and_test.sql
```

## 2. Modelagem Conceitual e Lógica

### 2.1. Visão Geral das Entidades

- **Pessoas (Supertipo):** armazena dados comuns a todos os usuários (nome, CPF, senhas e data de cadastro).
- **Alunos, Servidores, Externos, Administradores (Subtipos):** especializações 1:1 do supertipo, contendo atributos específicos de cada perfil.
- **Eventos:** representa cada evento disponível para inscrição, com nome, data, local e quantidade de vagas.
- **Inscricoes:** associa pessoas a eventos em uma relação N:M, armazenando status e data de inscrição.

### 2.2. Diagrama ER (orientações)

1. Modele o diagrama no MySQL Workbench utilizando a estratégia de herança por tabela filha (`id` compartilhado com o supertipo).
2. Exporte a imagem do diagrama para incluir no PDF final (menu *File > Export > Export as PNG/SVG*).

### 2.3. Normalização

- **1FN / 2FN / 3FN:** atributos atômicos, uso de chaves naturais/alternativas e remoção de dependências transitivas.
- **Redução de redundância:** subtipos armazenam apenas atributos específicos; informações comuns residem em `Pessoas`.
- **PK/FK:** identificadores inteiros (`INT`) com auto incremento no supertipo e replicados nos subtipos para manter a integridade 1:1.

### 2.4. Relacionamentos

- `Pessoas` 1:1 `Alunos/Servidores/Externos/Administradores` por meio de `ON DELETE CASCADE`.
- `Eventos` 1:N `Inscricoes`.
- `Pessoas` N:M `Eventos` via `Inscricoes`.

## 3. Estrutura das Tabelas

| Tabela | Descrição | Campos-chave e Restrições |
| --- | --- | --- |
| `Pessoas` | Dados comuns a todos os usuários. | `id_pessoa` (PK AUTO_INCREMENT), `cpf` (UNIQUE + CHECK de 11 dígitos), senhas em texto e SHA2, índices em `nome` e `cpf`. |
| `Alunos` | Complemento de pessoas do tipo aluno. | `id_aluno` (PK + FK `Pessoas`), `email` (UNIQUE), `matricula` (UNIQUE). |
| `Servidores` | Dados de servidores internos. | `id_servidor` (PK + FK), `tipo_servidor` (ENUM), `siape` (UNIQUE opcional). |
| `Externos` | Dados de convidados externos. | `id_externo` (PK + FK), `empresa` obrigatória, `email` (UNIQUE). |
| `Administradores` | Usuários com acesso privilegiado. | `id_admin` (PK + FK), `nivel_acesso` (CHECK 1-5). |
| `Eventos` | Registro de eventos disponíveis. | `id_evento` (PK), `vagas` (DEFAULT 100, CHECK >=0), índices em `nome` e `data_evento`. |
| `Inscricoes` | Relação N:M entre pessoas e eventos. | `id_inscricao` (PK), `UNIQUE(id_pessoa, id_evento)`, `status` (ENUM), FKs com `ON DELETE CASCADE`. |

## 4. Operações CRUD Demonstradas

### 4.1. Inserts

- 5 pessoas cadastradas (um representante de cada tipo + um aluno adicional).
- Senhas salvas em texto e criptografadas com `SHA2(..., 256)`.
- 2 eventos cadastrados com vagas e locais distintos.
- 3 inscrições relacionando pessoas e eventos.

### 4.2. Consultas

- `Q1` listagem geral de pessoas.
- `Q2` listagem de inscritos por evento com JOINs múltiplos.
- `Q3` cálculo de vagas restantes por evento com subquery correlacionada.
- `Q4` contagem por tipo de usuário usando `UNION ALL`.
- `Q5` subquery com `EXISTS` para inscritos externos confirmados.

### 4.3. Atualizações

- `U1` edita email de aluno.
- `U2` ajusta status de inscrição.
- `U3` muda tipo de servidor (enum).

### 4.4. Deleções

- `D1` remove inscrição específica dentro de transação com `ROLLBACK`.
- `D2` remove evento testando cascata sobre inscrições.
- `D3` remove pessoa, demonstrando cascata para subtipo e inscrições.

## 5. Testes e Evidências

Executar os testes abaixo individualmente (removendo `--` no script) e registrar *prints* do resultado no console:

| Código | Objetivo | Resultado esperado |
| --- | --- | --- |
| `T1` | Inserir CPF duplicado. | Erro `Duplicate entry ... for key 'uq_pessoas_cpf'`. |
| `T2` | Inserir administrador com nível inválido. | Erro de `CHECK constraint 'chk_admin_nivel'`. |
| `T3` | Criar inscrição sem pessoa correspondente. | Erro de FK `fk_inscricoes_pessoa`. |
| `T4` | Atualizar PK de pessoa manualmente. | Erro `Cannot update a primary key referenced in a foreign key constraint`. |
| `T5` | Excluir pessoa inexistente. | `Query OK, 0 rows affected`. |

**Orientações para registro de evidências:**

1. Rode cada query no MySQL Workbench ou CLI com `START TRANSACTION` quando necessário.
2. Capture o trecho do console exibindo o comando e o resultado (sucesso ou erro).
3. Inclua as imagens no PDF final, anotando brevemente o objetivo do teste e a conclusão.

## 6. Próximos Passos (Integração Web)

- Implementar camada de acesso (PHP) parametrizada para executar as operações do script.
- Utilizar `Prepared Statements` para manipulação de senhas e evitar SQL Injection.
- Criar *views* para relatórios frequentes (ex.: lista consolidada de inscritos confirmados).
- Planejar política de backup e restore (MySQL Dump) e revisão periódica de índices.

## 7. Considerações Finais

O banco de dados proposto atende aos requisitos funcionais e não funcionais do trabalho, oferecendo estrutura normalizada, integridade via chaves estrangeiras com `ON DELETE CASCADE` e segurança básica com armazenamento de senhas em forma criptografada. O arquivo `create_and_test.sql` centraliza a criação de esquema, dados de teste e operações CRUD, servindo como base para validação e futura integração com a aplicação web.

Para a entrega formal, gerar um PDF contendo:

1. Este conteúdo textual, ajustado conforme necessidade do professor.
2. O diagrama ER exportado do Workbench.
3. Capturas de tela das execuções das queries (sucesso/erro) com breve explicação.
4. Reflexões sobre desafios (ex.: impacto do `CASCADE` ao excluir usuários) e lições aprendidas.

Com isso, o trabalho fica completo e pronto para defesa ou apresentação em sala.
