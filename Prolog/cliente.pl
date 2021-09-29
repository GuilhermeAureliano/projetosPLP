:-use_module(library(csv)).
:- include('mensagens.pl').
:- include('util.pl').


loginCliente(Menu):-
    menuDoCliente,
    read(Opcao),
    opcoesCliente(Opcao, Menu),
    halt.

opcoesCliente(1, Menu):- listarVagasDisponiveis, loginCliente(Menu).
opcoesCliente(2, Menu):- escolherVaga(Menu), loginCliente(Menu).
opcoesCliente(3, Menu):- recomendarVaga, loginCliente(Menu). % Falta
opcoesCliente(4, Menu):- assinarContrato(Menu), loginCliente(Menu).
opcoesCliente(5, Menu):- contratosDosClientes(Menu), loginCliente(Menu). % Falta
opcoesCliente(6, Menu):- Menu.

%  Escolhe uma vaga das disponíveis
escolherVaga(Menu):-
    writeln("\nPara continuar vai ser preciso efetuar um cadastro no sistema!\n"),

    informeCpf,
    read(Cpf),
    
    lerArquivoCsv('cpvhs.csv', Result),
    ehMember(Cpf, Result, Resposta),
    (Resposta -> usuarioVagaOcupada, loginCliente(Menu) ; write("")),    
    
    lerArquivoCsv('clientes.csv', Result2),
    ehMember(Cpf, Result2, Resposta2),
    (Resposta2 -> usuarioCadastrado, cadastrarPlaca, read(Placa) ; write("")),

    informeNome,
    read(Nome),
    cadastrarPlaca,
    read(Placa),
    
    lerArquivoCsv('vagas.csv', Result3),
    writeln(Result3),
    writeln("\nQual vaga o senhor deseja?"),
    read(Vaga),

    writeln("\nDeseja adicionar servico extra de lava-jato e cera? [S/N]"),
    read(Service),

    cadastraHorarioEntrada,
    read(Hora),

    cadastrarCpv(Cpf, Placa, Vaga, Hora, Service),
    cadastrarCliente(Cpf, Nome, Placa),
    cadastradoEfetuado,
    opcaoVaga(Vaga).

listarVagasDisponiveis:-
    writeln("\n           -----LISTA DAS VAGAS DISPONIVEIS-----\n"),
    lerArquivoCsv('vagas.csv', Result),
    sort(Result, Sort),
    writeln(Sort).

recomendarVaga:-
    informeCpf,
    read(Cpf),
    
    writeln("Nos recomendamos a voce a vaga: ").

assinarContrato(Menu):-
    informeCpf,
    read(Cpf),

    lerArquivoCsv('contratos.csv', Result),
    ehMember(Cpf, Result, Resposta),
    (Resposta -> writeln("\nVoce ja tem contrato ativo! Tecle 5 na area do cliente para usar seu contrato!\n"), loginCliente(Menu) ; write("")), 

    writeln("Informe seu nome: "),
    read(Nome),

    cadastrarPlaca,
    read(Placa),

    listarVagasDisponiveis,

    writeln("Qual vaga voce deseja?"),
    read(Vaga),

    msgAssinarContrato,
    read(Contrato),

    cadastrarContrato(Cpf, Nome, Placa, Vaga, Contrato),
    writeln("\nContrato assinado com sucesso!"),
    opcaoVaga(Vaga),

    cadastrarUsoDoContrato(Cpf, 0, Contrato).

contratosDosClientes(Menu):-
    informeCpf,
    read(Cpf),

    lerArquivoCsv('usoDoContrato.csv', Result),
    ehMember(Cpf, Result, Resposta),
    (Resposta -> writeln("") ; writeln("\nO senhor nao tem contrato ativo!\n"), loginCliente(Menu)), 

    writeln("\nBem-vindo de volta! O senhor estara usando seu contrato!"),
    removegg(Cpf, Result, Lista),
    (renovacaoDeContrato(Lista) -> writeln("\nSeu contrato acabou! Deseja renovar? [s/n]"), read(Renova) ; writeln("")),

    lerArquivoCsv('contratos.csv', Result2),
    (Renova == 's' -> limpaCsv('usoDoContrato.csv'), reescreveRenovacao(Result, Cpf) ; excluirUsoDoContrato(Cpf, Result), excluirContratos(Cpf, Result2)).

    % limpaCsv('usoDoContrato.csv'),
    % reescreveUsoContrato(Result, Cpf).

