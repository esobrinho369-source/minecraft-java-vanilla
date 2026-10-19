# Minecraft Java Edition - VANILLA (sem mods ou plugins)
# Infraestrutura: GitHub + Railway, com volume persistente montado em /data.
# Imagem oficial do projeto itzg/docker-minecraft-server:
# https://github.com/itzg/docker-minecraft-server
FROM itzg/minecraft-server:latest

# Ajustes iniciais para cerca de 5 a 10 jogadores (dependem da carga real).
# A JVM pode usar ate 3 GB de heap; disponibilize ~4 GB ao container.
# Nao coloque EULA=TRUE aqui: aceite a EULA e configure a variavel no Railway.
ENV TYPE=VANILLA \
    VERSION=LATEST \
    INIT_MEMORY=1G \
    MAX_MEMORY=3G \
    MAX_PLAYERS=10 \
    MODE=survival \
    DIFFICULTY=normal \
    ONLINE_MODE=TRUE \
    VIEW_DISTANCE=8 \
    SIMULATION_DISTANCE=6 \
    MOTD="Vanilla dos Amigos" \
    ENABLE_RCON=FALSE

# Minecraft Java usa TCP; a porta publica sera criada no TCP Proxy do Railway.
EXPOSE 25565/tcp
