# Minecraft Java Vanilla (5-10 pessoas) — GitHub + Railway

Projeto simples para hospedar um **Minecraft Java Edition Vanilla** (servidor original da Mojang, sem Paper, plugins ou mods) no Railway, usando GitHub como origem da configuração. Baseado na imagem `itzg/minecraft-server`.

## Arquivos

- `Dockerfile` — instala e inicia automaticamente o Minecraft Java Vanilla; inclui os ajustes iniciais de memoria, distancia e jogadores.
- `railway-variables.example` — nomes de variaveis opcionais, com exemplos para a interface do Railway.
- `.gitignore` — impede que mundos/saves sejam enviados acidentalmente ao GitHub.
- `README.md` — este manual.

**Importante:** o mundo e os inventarios ficam no volume `/data` do Railway e **nao** no repositório GitHub. Nunca coloque seus arquivos de mundo em um repositório publico.

## 1. Criar o repositório no GitHub

1. No GitHub, clique em **New repository**.
2. Nome sugerido: `minecraft-java-vanilla`.
3. Acesse o novo repo, escolha **Add file → Upload files**.
4. Extraia o ZIP do projeto em seu computador e envie **os arquivos de dentro** da pasta, sem criar uma subpasta: `Dockerfile`, `README.md`, `.gitignore` e `railway-variables.example`.
5. Clique em **Commit changes**. Confirme que `Dockerfile` aparece na raiz do repositório.

## 2. Criar projeto no Railway

1. Acesse https://railway.com/ e autentique-se.
2. Abra **New Project → Deploy from GitHub Repo**; autorize o acesso ao repo e selecione `minecraft-java-vanilla`.
3. Se aparecer a opção **Add Variables**, prefira usá-la antes de iniciar o primeiro deploy.
4. Leia a EULA de Minecraft em https://aka.ms/MinecraftEULA. **Somente se concordar**, adicione na aba **Variables**: `EULA=TRUE`. Se não concordar, não configure essa variável e não execute o servidor.
5. O Railway detecta automaticamente o arquivo `Dockerfile`. Se um primeiro deploy falhar pela ausência da EULA, isso é esperado até configurá-la.

## 3. Criar volume persistente (INDISPENSÁVEL)

1. No projeto do Railway, crie um **Volume** e conecte-o ao serviço Minecraft; use o **Mount Path `/data`**.
2. Faça isso **antes do primeiro jogo**: sem volume, um deploy/recriação do container pode apagar o mundo e os inventários.
3. O plano Hobby tem tamanho padrão de volume de 5 GB; mundos maiores podem exigir ampliação do volume.
4. No serviço, abra a aba **Backups** e configure backups; considere backups manuais antes de mudar `VERSION`.
5. Se aparecer erro de permissao relacionado a `/data`, considere adicionar `RAILWAY_RUN_UID=0` na aba Variables e reiniciar. Consulte a documentação de volumes do Railway.

## 4. Criar o endereço público do jogo

1. Selecione o serviço Minecraft no Railway.
2. Vá a **Settings → Networking → TCP Proxy**.
3. Informe **25565** (a porta **interna**, TCP, do servidor).
4. Copie o `domínio:porta` público gerado; exemplo fictício: `shuttle.proxy.rlwy.net:15140`.
5. **Não use um domínio HTTP/HTTPS normal** para tentar conectar o cliente Minecraft. Não assuma que a porta pública é 25565.

## 5. Primeiro acesso pelo Minecraft Java

1. Espere aparecer `Done` nos logs do serviço (o primeiro inicio pode demorar pela instalação e geração do mundo).
2. Use o **Minecraft Java Edition** na **mesma versão do servidor**.
3. Vá a **Multijogador → Adicionar servidor**.
4. Cole o endereço `domínio:porta` que o Railway exibiu em TCP Proxy.
5. Conecte-se e teste com um amigo.

## Configuração padrão (Dockerfile)

| Variável | Valor | Explicação |
|---|---|---|
| `TYPE` | `VANILLA` | Sem Paper, mods ou plugins |
| `VERSION` | `LATEST` | Versão estável mais recente disponível no início; **fixe a versão depois dos testes** |
| `INIT_MEMORY` | `1G` | Heap Java inicial |
| `MAX_MEMORY` | `3G` | Heap Java máximo; a RAM total do container deve ter folga (~4 GB) |
| `MAX_PLAYERS` | `10` | Vagas máximas; não garante desempenho |
| `MODE` | `survival` | Sobrevivência |
| `DIFFICULTY` | `normal` | Dificuldade normal |
| `ONLINE_MODE` | `TRUE` | Exige autenticação legítima do Minecraft |
| `VIEW_DISTANCE` | `8` | Chunks visíveis, redução moderada de carga |
| `SIMULATION_DISTANCE` | `6` | Chunks simulados, menor consumo de recursos |
| `MOTD` | `Vanilla dos Amigos` | Nome/descrição exibidos na lista |
| `ENABLE_RCON` | `FALSE` | Desativa controle remoto RCON, que não será usado |

Variáveis criadas em **Railway → Variables** substituem os valores `ENV` do Dockerfile. Evite configurar um mesmo valor nos dois lugares sem saber qual prevalece.

### Impedir a entrada de desconhecidos (recomendado)

No Railway, adicione na aba **Variables**:

`WHITELIST=Nick1,Nick2,Nick3`

Substitua pelos nicks reais de todas as pessoas que podem entrar. A imagem `itzg/minecraft-server` habilita a whitelist quando `WHITELIST` é informado. Confirme os nomes antes de ativar, porque pessoas omitidas não conseguirão entrar. Para dar privilégios administrativos ao dono, opcionalmente configure `OPS=SeuNickMinecraft`.

### Usar uma versão específica

Quando souber a versão desejada, coloque `VERSION=VERSAO_EXATA` na aba Variables (exemplo fictício: `VERSION=1.xx.x`) ou altere o `Dockerfile`. Use a mesma versão no launcher do Minecraft Java. **Não reverta para versões antigas em um mundo já aberto por uma versão mais recente** sem backup.

### Ajustes de desempenho

- Cerca de 4 GB de RAM disponível no serviço é uma referência inicial para 5-10 pessoas; o Java usa até 3 GB de heap, além da memória não-heap e do sistema. A necessidade real depende de quantos jogam simultaneamente, exploração do mapa e entidades.
- Se houver lag, diminua `VIEW_DISTANCE` para `6` e `SIMULATION_DISTANCE` para `4` e verifique uso real de CPU e memória na aba Metrics.
- `MAX_PLAYERS=10` apenas limita conexões, não garante que dez jogadores possam explorar sem lag.

## Custo (IMPORTANTE)

O Railway Free tem máximo de 0,5 GB RAM por serviço, e o Trial tem até 1 GB; não são suficientes para esta configuração. O plano Hobby custa US$ 5/mês, **mas esse valor não é teto de gasto**: há cobrança por uso medido de RAM, CPU, armazenamento e tráfego, com crédito do plano incluído. Um servidor 24/7 com varios GB de RAM pode custar muito mais de US$ 5 por mês.

Veja os preços atuais: https://docs.railway.com/pricing/plans

Recomendamos configurar **Workspace Usage → Usage Limits**, com alertas e limite de gasto, e acompanhar Metrics. Atenção: quando um limite rígido é atingido, o Railway desliga os serviços até haver saldo/limite disponível.

## Resolução de problemas

- **Erro EULA**: faltou configurar `EULA=TRUE` após aceitar os termos.
- **`Connection refused`/timeout**: confira se a aplicação iniciou (`Done` nos logs), se o TCP Proxy aponta para porta interna `25565`, e se está usando `domínio:porta` completos.
- **`OutOfMemory`**: verifique métricas e memória real; o container precisa de folga além do valor `MAX_MEMORY`.
- **Permissão negada em `/data`**: confira volume e consulte o caso `RAILWAY_RUN_UID=0` descrito acima.
- **Versão incompatível**: cliente e servidor Minecraft Java precisam usar versões compatíveis. Fixe `VERSION` após conferir nos logs a versão instalada.
- **Sumiu o mundo**: confirme que o mesmo volume está montado em `/data`; não confunda com dados efêmeros do deploy.

## Documentação

- Railway (GitHub e serviços): https://docs.railway.com/services
- Railway TCP Proxy: https://docs.railway.com/networking/tcp-proxy
- Railway volumes: https://docs.railway.com/volumes
- Railway backups: https://docs.railway.com/volumes/backups
- Railway custos: https://docs.railway.com/pricing/plans
- Controle de gastos: https://docs.railway.com/pricing/cost-control
- itzg Minecraft Server: https://itzg.github.io/docker-minecraft-docs/
