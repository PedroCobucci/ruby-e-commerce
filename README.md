# API E-commerce - API de Carrinho de Compras

O projeto foi desenvolvido com foco nos princípios de **Clean Code**, performance e manutenibilidade, seguindo as melhores práticas do ecossistema Ruby on Rails. A aplicação está totalmente dockerizada para garantir um ambiente de desenvolvimento consistente e de fácil configuração.

## 📋 Índice

* [Como Executar o Projeto (Docker)](#-como-executar-o-projeto-docker)
* [Executando os Testes](#-executando-os-testes)
* [Decisões de Arquitetura e Design](#-decisões-de-arquitetura-e-design)

## Pré-requisitos

Antes de começar, certifique-se de que você tem as seguintes ferramentas instaladas:

* [Docker](https://www.docker.com/get-started)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Um terminal Unix-like (Linux, macOS ou WSL no Windows).

## Como Executar o Projeto (Docker)

O projeto foi configurado para ser executado de forma simples e rápida com Docker. Siga os passos abaixo:

**1. Clone o Repositório**

**2. Configure as Variáveis de Ambiente**

```bash
mv env.example .env
```
**3. Instale o Script Auxiliar**

(talvez precise rodar `chmod +x ./rd`)
```bash
./rd setup
source ~/.bashrc
rd
```

teste! Deve exibir uma interface com os comandos disponíveis.

```bash
rd
```

**4. Construa as Imagens Docker**

```bash
docker build --build-arg UID=$UID -t rd-commerce .
```
```bash
docker compose build
```

**5. Instale as gems**

```bash
rd run bundle install
```
```bash
rd run_test bundle install
```

**6. Crie o banco de dados**

```bash
rd db:setup
```

**7. Inicie a Aplicação**
```bash
rd start
```

Pronto! A API estará rodando em http://localhost:3000.


## Como Executar os testes
Para executar os testes:

```bash
rd test
```

## Decisões de Arquitetura e Design

As escolhas de arquitetura foram focadas em criar uma solução limpa, performática e de fácil manutenção.

1.  **Arquitetura MVC com Service Layer**
    Adotei uma **Service Layer** (`CartService`) para isolar a lógica de negócio, seguindo o princípio de *Skinny Controllers*. Isso mantém as controllers focadas no fluxo HTTP, resultando em um código mais organizado e fácil de testar.

2.  **Redis**
    O Redis foi utilizado como peça central de alta performance em três frentes: como **Cache Store** para reduzir a carga no banco de dados, como backend para o **Sidekiq** garantindo a execução confiável de jobs, e como **Session Store** para permitir escalabilidade futura da aplicação.

3.  **Cache Inteligente com Invalidação Automática**
    Implementei o cache do carrinho da sessão com **invalidação automática e segura**. Usando `touch: true` nas associações e um callback `after_commit` no model `Cart`, garantimos que o cache seja invalidado imediatamente após qualquer modificação ser confirmada no banco de dados, evitando dados desatualizados.

4.  **Jobs Concisos com Scopes no ActiveRecord**
    A lógica do Sidekiq Job foi simplificada e tornada mais legível com o uso de **Scopes** no model `Cart` (ex: `Cart.abandonable`). Isso limpa o código do worker e segue o princípio DRY. O `touch: true` nos itens do carrinho também é fundamental aqui, pois ele atualiza o timestamp de inatividade (`last_interaction_at`) que alimenta a lógica do job.

