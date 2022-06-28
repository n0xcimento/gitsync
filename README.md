That is a simple script to synchronize my git repositories, in automatic form, without have to do each basic git command at each git repository.

Usage:

```
gitsync [-lhv] [--pull] [--push MSG] [--dir DIR...]

    --pull  Faz download das mudanças do repositório remoto e faz merge.
    --push  Manda as mudanças locais para os diretórios remotos,
            MSG obrigatório para o commit.
    --dir   Especifica diretórios.

    -l      Mostra a lista de diretórios que possuem mudanças
    -h      Mostra a tela de ajuda e sai
    -v      Mostra a versão do programa e sai
```