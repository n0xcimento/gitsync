#!/bin/bash
# gitsync..sh
#
# Manda as mudanças nos diretórios Git, listado em $dirList, para o repositório
# no GitHub.
#
# Versão 0.1: Verifica se há mundanças nos diretórios e mostra quais são eles
# Versão 0.2: Mostra os diretórios que tiveram mudanças, colorido
# Versão 0.3: Adicionada opções de linha de comando para listar diretórios que possuem
#            mudanças, página de ajuda, mostrar versão, mandar mudanças, baixar mudanças.
# Versão 0.4: Opção --dir adicionada, usada para especificar os diretórios que o programa irá processar
#
# Yuri, Maio de 2022
#


# CHAVES
listar_dir_mudancas=0           # listar os diretórios que possuem mudanças?
baixar_mudancas_remotas=0       # baixar mudanças do repositório remoto?
mandar_mudancas_locais=0        # mandar as mudanças locais para o repositório remoto?
diretorios_especificos=0        # verificar por mudanças apenas nos diretóios especificados?
mostrar_msg_uso=0               # mostrar a mensagem de uso, do programa?



# VARIÁVEIS UTILITÁRIAS
MENSAGEM_USO="
Uso: `basename "$0"` [-lhv] [--pull] [--push \"MSG\"] [--dir DIR...]

    --pull  Faz download das mudanças do repositório remoto e faz merge 
    --push  Manda as mudanças locais para os diretórios remotos,
            MSG obrigatório para o commit
    --dir   Especifica diretórios

    -l      Mostra a lista de diretórios que possuem mudanças
    -h      Mostra a tela de ajuda e sai
    -v      Mostra a versão do programa e sai
"

# Especifica os meus diretórios Gits que o programa irá processar, por padrão.
# Especificando dessa forma, o uso da opção --dir não é necessária
dirList="
    ebook Periodo.04
"

dirMudancas=""      # Lista com os diretórios que há mudanças

MSG=""      # MSG para o commit


# Nenhuma opção passada
if [ -z "$1" ]
then
    mostrar_msg_uso=1
fi

# Tratamento das opções de linha de comando
while test -n "$1"
do
    case "$1" in

        --push)
            mandar_mudancas_locais=1
            shift
            MSG="$1"

            if test -z "$1"
            then
                echo -e "Faltou a MSG para o commit.\n\t`basename "$0"` [--push \"MSG\"]"
                exit 1
            fi
        ;;

        --pull)
            baixar_mudancas_remotas=1
        ;;

        --dir)
            diretorios_especificos=1
            dirList=""
            while test -n "$1"; do
                shift
                # valida somente os diretórios Gits, aqueles que possuem o .git
                if test "$(find $1 -maxdepth 1 -type d -name .git | wc -l)" = 1; then
                    dirList="$1 $dirList"
                    # echo "$dirList"
                fi
            done
        ;;

        -l)
            listar_dir_mudancas=1
        ;;

        -h)
            mostrar_msg_uso=1
        ;;

        -v)
            echo -n `basename $0`
            egrep '^# Versão ' "$HOME/Programming/sh/$0" | tail -1 | cut -d : -f 1 | tr -d \#
            exit 0
        ;;

        *)
            echo "Opção inválida: $1"
            exit 1
        ;;

    esac

    # Opção $1 já processada, deslocar os parâmetros em 1 para esquerda
    shift
done


# Mostra a mensagem de uso, caso seja passada a opção -h ou nenhuma opção
if [ "$mostrar_msg_uso" = 1 ]
then
    echo "$MENSAGEM_USO"
    exit 1
fi


# Pega os diretórios que possuem mudanças ou possui arquivos que não foram rastreados pelo git
for dir in $dirList; do
    git -C "`pwd`/$dir" status | egrep -qi "(not staged|untracked)"

    if test "$?" = 0
    then
        # echo -e "Changes in [\e[01;33m$dir\e[m]"
        dirMudancas="$dir $dirMudancas"
    fi
done


# Lista os diretórios que possuem mudanças ou possuem arquivos que não foram trackeados
if test "$listar_dir_mudancas" = 1
then
    for dir in $dirMudancas
    do
        echo -e "Changes in [\e[01;33m$dir\e[m]"
    done
fi


# Manda as mudanças locais para o repositório remoto
if test "$mandar_mudancas_locais" = 1
then
    for dir in $dirMudancas
    do
        git -C "$HOME/$dir" add .
        git -C "$HOME/$dir" commit -m "$MSG"
        git -C "$HOME/$dir" push
    done
fi


# Baixa as mudanças dos repositórios remotos e faz merge(pull) em cada repositório local
# que não possui as novas mudanças do remoto.
if test "$baixar_mudancas_remotas" = 1
then
    for dir in $dirList
    do
        git -C "$HOME/$dir" pull
    done
fi
