# Active Suspension SHM

Este projeto consiste em um estudo do monitoramento da saúde estrutural (_Structural Health Monitoring_ - SHM) de uma suspensão ativa por meio da abordagem de observadores de estado. Os programas e simulações foram desenvolvidos durante o projeto de graduação (TG) do curso de Engenharia de Instrumentação, Automação e Robótica na Universidade Federal do ABC (UFABC).

## Considerações iniciais

* Este projeto foi desenvolvido utilizando a versão 2023b do MATLAB e, portanto, recomenda-se a utilização desta versão para a execução dos códigos e simulações aqui disponibilizados.

* No diretório **docs** tem-se em PDF tanto a monografia desenvolvida (em que explica-se em detalhe todo o propósito deste trabalho) quanto versões em PDF dos live scripts utilizados neste projeto.

## Estrutura do projeto

Visando documentar o código com mais legibilidade e tornar o programa mais interativo, utilizou-se [live scripts](https://www.mathworks.com/help/matlab/matlab_prog/what-is-a-live-script-or-function.html). A nível geral, este projeto é composto por dois scripts principais:

### main
Presente no diretório raiz, este live script é responsável por trazer todas as representações utilizadas durante o TG, incluindo os ruídos sobrepostos para cada possbilidade de sistema, diagrama de Bode do filtro e etc. Na primeira seção do arquivo têm-se os parâmetros utilizados na simulação, velocidades dos polos (que podem ser aqueles determinados na execuação do script **design_obs**) e etc. Este script pode ser exectuado tanto pela interface do live script quanto pela linha de comando do MATLAB por meio de:
```matlab
>> run main
```

### design_obs
Presente no diretório **observer_design**, este script é utilizado para auxliar na determinação dos melhores polos para cada um dos observadores de Luenberger e determinar os limiares utilizados para o classificador. Para executá-lo, basta acessar o referido diretório, abrir o live script **design_obs.mlx** e executar o arquivo pela própria interface do MATLAB. Para facilitar, a velocidade dos polos é definida com base em um slider e toda vez que o usuário clica em "Run", gera-se os ruídos (utilizados para definir o melhor observador). Vale destacar que os parâmetros utilizados nesse script <u>**devem**</u> ser os mesmos daqueles utilizados no script **main.mlx**.  


<u>Obs</u>.: Para que seja possível executar o arquivo **main.mlx**, é necessário que o caminho atual (_Current Path_) do usuário seja diretório raiz enquanto para a execução de **design_obs.mlx** o diretório atual do usuário deve ser **observer_design**.

<!-- 
## Melhorias futuras
-->