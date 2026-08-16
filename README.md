# SagiOS

Distro Linux baseada em Arch Linux, com ambiente desktop KDE Plasma, gerada via [archiso](https://wiki.archlinux.org/title/Archiso).

A ISO é buildada **automaticamente na nuvem pelo GitHub Actions** — você não precisa compilar nada na sua máquina.

## Como gerar a ISO (passo a passo)

1. Crie um repositório novo no GitHub (pode ser privado ou público).
2. Suba todos os arquivos desta pasta para esse repositório (pela interface web do GitHub: "Add file" → "Upload files", arraste tudo, e faça commit direto na branch `main`).
3. Vá na aba **Actions** do repositório.
4. Você verá o workflow "Build SagiOS ISO". Clique nele → **Run workflow** → **Run workflow** de novo pra confirmar.
5. Aguarde ~15 a 25 minutos (o Arch Linux precisa baixar o KDE Plasma inteiro e gerar a imagem).
6. Quando terminar (bolinha verde ✅), clique na execução → role até **Artifacts** → baixe `sagios-iso`.
7. Dentro do zip baixado está o arquivo `sagios-XXXX.iso` — essa é a sua ISO bootável, pronta pra gravar num pendrive (com [Ventoy](https://www.ventoy.net/) ou [Rufus](https://rufus.ie/)) ou rodar numa VM (VirtualBox/VMware/QEMU).

## O que está incluso

- **Desktop**: KDE Plasma completo (Dolphin, Konsole, Kate, Ark, Spectacle, Gwenview, Okular, etc.)
- **Rede**: NetworkManager configurado e habilitado no boot
- **Áudio**: PipeWire
- **Instalador gráfico**: Calamares (permite instalar o SagiOS no disco, não só rodar live)
- **Autologin**: o sistema já entra direto no Plasma como usuário `liveuser` (padrão de qualquer live ISO)
- **Branding**: nome "SagiOS" no `/etc/os-release`, neofetch, etc.

## Estrutura do projeto

```
sagios-project/
├── .github/workflows/build-iso.yml   → o robô que builda a ISO na nuvem
├── build.sh                          → script que monta o perfil archiso + aplica customizações
├── overlay/
│   ├── packages-extra.txt            → lista de pacotes do KDE Plasma e apps
│   └── airootfs/                     → arquivos que vão direto pro sistema de arquivos da ISO
│       ├── etc/os-release            → branding "SagiOS"
│       ├── etc/sddm.conf.d/          → autologin + tema Breeze
│       └── etc/systemd/system/       → habilita SDDM e NetworkManager no boot
└── README.md
```

Como funciona por baixo: o `build.sh` copia o perfil oficial `releng` do archiso (a base testada e mantida pelo próprio time do Arch) e só *soma* as customizações do SagiOS em cima — isso garante que o boot, o bootloader (BIOS/UEFI) e a estrutura da ISO continuam corretos, sem eu precisar reinventar essas partes manualmente.

## Se o build falhar na primeira vez

Eu não consegui testar esse build de verdade antes de te entregar (meu ambiente aqui não tem acesso à internet). As causas mais prováveis de um erro na primeira tentativa:

- **Nome de pacote mudou/foi renomeado** no repositório do Arch → a mensagem de erro do `pacman` vai dizer qual pacote não foi encontrado; é só remover ou corrigir a linha correspondente em `overlay/packages-extra.txt`.
- **Espaço em disco do runner** → se a imagem ficar grande demais, pode faltar espaço no runner gratuito do GitHub. Nesse caso, dá pra remover pacotes menos essenciais (ex: `firefox`, `calamares`) do `packages-extra.txt` pra deixar a ISO mais enxuta.

Se travar em algo, me manda o log de erro da aba Actions que eu te ajudo a corrigir.

## Customizar depois

- **Trocar wallpaper/tema**: adicione arquivos em `overlay/airootfs/usr/share/wallpapers/` e `overlay/airootfs/etc/skel/.config/`.
- **Adicionar mais programas**: adicione o nome do pacote (do repositório oficial do Arch) em `overlay/packages-extra.txt`.
- **Mudar o nome de usuário live**: edite `overlay/airootfs/etc/sddm.conf.d/sagios_autologin.conf`.

Depois de qualquer mudança, é só dar commit/push que o Actions builda uma ISO nova automaticamente.
