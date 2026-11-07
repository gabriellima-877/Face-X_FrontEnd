import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects // Coisas de gráfico bonitinho (o efeito de blur)

Item {
    id: root
    anchors.fill: parent // Ocupa a tela inteira

    // === FUNDO BONITO (Tudo pra deixar o fundo escuro e embaçado) ===
    Rectangle {
        anchors.fill: parent
        color: "#0B101D" // Cor escura base se a imagem falhar
        z: 0
    }

    Image {
        id: bgImageSource
        anchors.fill: parent
        source: "https://www.espacohausimoveis.com.br/blog/wp-content/uploads/2024/05/53439242167_0bcfe4efd5_k.jpg" // Imagem de fundo escondida só pra alimentar o blur
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    FastBlur {
        id: bgBlur
        anchors.fill: parent
        source: bgImageSource
        radius: 30 // O tanto que vai embaçar a imagem
        cached: true
        z: 1
    }

    Rectangle {
        anchors.fill: parent
        color: "#0B101D"
        opacity: 0.85 // Camada escura por cima do blur pra não doer o olho
        z: 2
    }

    // === DADOS DA TELA PRINCIPAL (Pega do item selecionado da lista) ===
    property int indexOcorrenciaSelecionada: 0
    property string idOcorrenciaAtiva: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).idOcorrencia : "-"
    property string nomeProcurado: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).nome : "Nenhuma ocorrência"
    property string statusProcurado: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).situacao : "-"
    property string similaridade: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).sim : "-"
    property string localDetectado: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).local : "-"
    property string dataHora: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).dataHora : "-"
    property string idadeProcurado: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).idade : "-"
    property string crimeProcurado: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).crime : "-"
    property string cameraDetectada: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).cam : "-"
    property string ocorrenciaStatus: modeloOcorrencias.count > 0 ? modeloOcorrencias.get(indexOcorrenciaSelecionada).status : "-"

    // === BANCO DE DADOS DE MENTIRA (Mockups pra testar na tela) ===
    ListModel {
        id: modeloOcorrencias
        ListElement {
            idOcorrencia: "ID 37"
            nome: "Gustavo Henrique"
            sim: "58.76%"
            cam: "CAM-001"
            idade: "19 anos"
            situacao: "SUSPEITO"
            crime: "Roubo — SIMULAÇÃO"
            local: "Faculdade"
            status: "PENDING"
            dataHora: "2026-10-29 19:23:24.868966"
        }
    }

    ListModel {
        id: modeloCadastrados
        ListElement { idCad: "2"; nome: "Gabriel Ferro"; idade: "21"; situacao: "SUSPEITO"; cadastro: "ATIVO"; descricao: "Suspeito de furto na região central" }
        ListElement { idCad: "1"; nome: "Gustavo Henrique"; idade: "19"; situacao: "SUSPEITO"; cadastro: "ATIVO"; descricao: "Roubo — SIMULAÇÃO" }
        ListElement { idCad: "3"; nome: "Henrique Keller"; idade: "47"; situacao: "PROCURADO"; cadastro: "ATIVO"; descricao: "Mandado de prisão em aberto" }
    }

    ListModel {
        id: modeloHistorico
        ListElement { idOcorrencia: "35"; dataHora: "16/10/2026 19:47:11"; pessoa: "Gustavo Henrique"; camera: "CAM-001"; similaridade: "86.42%"; status: "DISCARDED" }
        ListElement { idOcorrencia: "34"; dataHora: "16/10/2026 19:45:46"; pessoa: "Gustavo Henrique"; camera: "CAM-001"; similaridade: "92.03%"; status: "DISCARDED" }
        ListElement { idOcorrencia: "33"; dataHora: "16/10/2026 18:58:07"; pessoa: "Henrique Keller"; camera: "CAM-001"; similaridade: "97.90%"; status: "CONFIRMED" }
        ListElement { idOcorrencia: "32"; dataHora: "16/10/2026 18:52:52"; pessoa: "Gustavo Henrique"; camera: "CAM-001"; similaridade: "83.31%"; status: "DISCARDED" }
        ListElement { idOcorrencia: "31"; dataHora: "16/10/2026 18:51:21"; pessoa: "Gabriel Ferro"; camera: "CAM-001"; similaridade: "77.10%"; status: "PENDING" }
        ListElement { idOcorrencia: "30"; dataHora: "16/10/2026 18:48:56"; pessoa: "Gabriel Ferro"; camera: "CAM-001"; similaridade: "82.47%"; status: "CONFIRMED" }
    }

    // === LÓGICA DE CONFIRMAR / DESCARTAR ===
    function responderOcorrencia(novoStatus) {
        if (modeloOcorrencias.count === 0) return // Sem ocorrência? Faz nada.

        var itemAtual = modeloOcorrencias.get(root.indexOcorrenciaSelecionada)
        var numId = itemAtual.idOcorrencia.replace("ID ", "")

        // Joga pro histórico
        modeloHistorico.insert(0, {
            idOcorrencia: numId,
            dataHora: itemAtual.dataHora,
            pessoa: itemAtual.nome,
            camera: itemAtual.cam,
            similaridade: itemAtual.sim,
            status: novoStatus
        })

        // Tira da lista da tela principal
        modeloOcorrencias.remove(root.indexOcorrenciaSelecionada)
        if (root.indexOcorrenciaSelecionada >= modeloOcorrencias.count) {
            root.indexOcorrenciaSelecionada = Math.max(0, modeloOcorrencias.count - 1)
        }
    }

    // === LAYOUT PRINCIPAL (O que aparece na tela sem modais) ===
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10
        z: 3

        // Topo da tela (Logo e título)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            RowLayout {
                spacing: 10
                Text { text: "FACE-X"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 18 }
                Image {
                    id: imgLogo
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    fillMode: Image.PreserveAspectFit
                    source: "Logo.png"
                }
                Text { text: "CENTRAL DE VERIFICAÇÃO"; color: "#8674CC"; font.bold: true; font.pixelSize: 12 }
            }

            Item { Layout.fillWidth: true } // Espaçador empurra o resto pra direita

            Text {
                text: modeloOcorrencias.count + " ocorrência(s) ativa(s)"
                color: "#38BDF8"
                font.pixelSize: 12
            }
        }

        // Meio da tela (Lista na esquerda, Detalhes na direita)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Lista lateral das ocorrências rolando agora
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#131B2E"
                radius: 4
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text { text: "OCORRÊNCIAS ATIVAS"; color: "#E2E8F0"; font.bold: true; font.pixelSize: 11 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#0B101D"
                        radius: 2
                        border.color: "#1E293B"

                        ListView {
                            id: listOcorrencias
                            anchors.fill: parent
                            clip: true
                            model: modeloOcorrencias

                            delegate: Rectangle {
                                width: listOcorrencias.width
                                height: 28
                                color: root.indexOcorrenciaSelecionada === index ? "#38BDF8" : "#1C2541" // Destaca se tiver selecionado

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4
                                    Text { text: model.idOcorrencia; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }
                                    Text { text: "|"; color: "#FFFFFF" }
                                    Text { text: model.nome; color: "#FFFFFF"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: "|"; color: "#FFFFFF" }
                                    Text { text: model.sim; color: "#FFFFFF"; font.pixelSize: 11 }
                                    Text { text: "|"; color: "#FFFFFF" }
                                    Text { text: model.cam; color: "#FFFFFF"; font.pixelSize: 11 }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.indexOcorrenciaSelecionada = index // Clica pra ver os detalhes no lado
                                }
                            }
                        }
                    }
                }
            }

            // Quadrados de visualização de foto e textos do procurado
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    // Foto de referência
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        color: "#131B2E"; radius: 4; border.color: "#1E293B"
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10
                            Text { text: "FOTO DE REFERÊNCIA"; color: "#E2E8F0"; font.bold: true; font.pixelSize: 11 }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; color: "#0B101D"; radius: 2
                                Text { anchors.centerIn: parent; text: "Visualização Foto Referência"; color: "#475569"; font.pixelSize: 11 }
                            }
                        }
                    }

                    // Foto pega pela câmera
                    Rectangle {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        color: "#131B2E"; radius: 4; border.color: "#1E293B"
                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 10
                            Text { text: "FRAME CAPTURADO"; color: "#E2E8F0"; font.bold: true; font.pixelSize: 11 }
                            Rectangle {
                                Layout.fillWidth: true; Layout.fillHeight: true; color: "#0B101D"; radius: 2
                                Text { anchors.centerIn: parent; text: "Visualização Frame Capturado"; color: "#475569"; font.pixelSize: 11 }
                            }
                        }
                    }
                }

                // Bloco das informações escritas
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 185
                    color: "#131B2E"
                    radius: 4
                    border.color: "#1E293B"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text { text: "INFORMAÇÕES DO PROCURADO"; color: "#E2E8F0"; font.bold: true; font.pixelSize: 12 }

                        // Tabela com os textos formatados
                        GridLayout {
                            columns: 4
                            rowSpacing: 4; columnSpacing: 20
                            Layout.fillWidth: true

                            Text { text: "Nome:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.nomeProcurado; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Idade:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.idadeProcurado; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Status:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.statusProcurado; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Crime:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.crimeProcurado; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Similaridade:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.similaridade; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Câmera:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.cameraDetectada; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Local:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.localDetectado; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Ocorrência:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.ocorrenciaStatus; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                            Text { text: "Detectado em:"; color: "#94A3B8"; font.pixelSize: 11 }
                            Text { text: root.dataHora; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11; Layout.columnSpan: 3 }
                        }

                        Item { Layout.fillHeight: true }

                        // Botões de ação da ocorrência
                        RowLayout {
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 110
                                Layout.preferredHeight: 30
                                radius: 2
                                color: modeloOcorrencias.count > 0 ? "#2DD4BF" : "#475569" // Fica cinza se não tiver nada pra clicar
                                Text { anchors.centerIn: parent; text: "CONFIRMAR"; color: "#0F172A"; font.bold: true; font.pixelSize: 11 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: modeloOcorrencias.count > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.responderOcorrencia("CONFIRMED")
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 110
                                Layout.preferredHeight: 30
                                radius: 2
                                color: modeloOcorrencias.count > 0 ? "#EF4444" : "#475569"
                                Text { anchors.centerIn: parent; text: "DESCARTAR"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: modeloOcorrencias.count > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: root.responderOcorrencia("DISCARDED")
                                }
                            }
                        }
                    }
                }
            }
        }

        // Rodapé da tela com os botões de abrir as janelas/modais
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            spacing: 10

            Text { text: "Central conectada — monitoramento ativo"; color: "#64748B"; font.pixelSize: 11 }
            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 180; Layout.preferredHeight: 32; color: "#1E293B"; radius: 2
                Text { anchors.centerIn: parent; text: "HISTÓRICO DE OCORRÊNCIAS"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modalHistorico.visible = true // Abre a modal do histórico
                }
            }

            Rectangle {
                Layout.preferredWidth: 160; Layout.preferredHeight: 32; color: "#1E293B"; radius: 2
                Text { anchors.centerIn: parent; text: "GERENCIAR CADASTRADOS"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modalGerenciar.visible = true // Abre a modal de cadastro
                }
            }

            Rectangle {
                Layout.preferredWidth: 150; Layout.preferredHeight: 32; color: "#38BDF8"; radius: 2
                Text { anchors.centerIn: parent; text: "ADICIONAR SUSPEITO"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modalAdicionar.visible = true // Abre a modal de adicionar
                }
            }
        }
    }

    // =========================================================
    // MODAL 1: ADICIONAR SUSPEITO (Janela pop-up 1)
    // =========================================================
    Rectangle {
        id: modalAdicionar
        anchors.fill: parent
        color: "#B0000000" // Fundo escuro cobrindo a tela toda
        visible: false
        z: 9999 // Garante que fica por cima de tudo

        MouseArea { anchors.fill: parent } // Bloqueia cliques no fundo

        Rectangle {
            width: 480
            height: 520
            anchors.centerIn: parent
            color: "#0F172A"
            border.color: "#1E293B"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "FACE-X — Adicionar suspeito"; color: "#94A3B8"; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"; color: "#94A3B8"; font.pixelSize: 14; font.bold: true
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalAdicionar.visible = false }
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Layout.alignment: Qt.AlignHCenter
                    Text { text: "ADICIONAR SUSPEITO"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 17; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Preencha os dados e selecione uma foto frontal nítida."; color: "#94A3B8"; font.pixelSize: 11; Layout.alignment: Qt.AlignHCenter }
                }

                // Form de cadastro
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        spacing: 4; Layout.fillWidth: true
                        Text { text: "Nome completo"; color: "#FFFFFF"; font.pixelSize: 11; font.bold: true }
                        TextField { id: addNome; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; background: Rectangle { color: "#1C2541"; radius: 3 } }
                    }

                    ColumnLayout {
                        spacing: 4; Layout.fillWidth: true
                        Text { text: "Idade"; color: "#FFFFFF"; font.pixelSize: 11; font.bold: true }
                        TextField { id: addIdade; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; background: Rectangle { color: "#1C2541"; radius: 3 } }
                    }

                    ColumnLayout {
                        spacing: 4; Layout.fillWidth: true
                        Text { text: "Situação"; color: "#FFFFFF"; font.pixelSize: 11; font.bold: true }
                        ComboBox { id: addSituacao; Layout.fillWidth: true; Layout.preferredHeight: 34; model: ["SUSPEITO", "PROCURADO"] }
                    }

                    ColumnLayout {
                        spacing: 4; Layout.fillWidth: true
                        Text { text: "Descrição / ocorrência associada"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }
                        TextField { id: addDescricao; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; background: Rectangle { color: "#1C2541"; radius: 3 } }
                    }

                    ColumnLayout {
                        spacing: 4; Layout.fillWidth: true
                        Text { text: "Foto de referência"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 8
                            TextField { id: addFotoPath; Layout.fillWidth: true; Layout.preferredHeight: 34; placeholderText: "Caminho da foto..."; background: Rectangle { color: "#E2E8F0"; radius: 3 } }
                            Rectangle {
                                Layout.preferredWidth: 90; Layout.preferredHeight: 34; color: "#38BDF8"; radius: 3
                                Text { anchors.centerIn: parent; text: "ESCOLHER"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: addFotoPath.text = "C:/Imagens/foto.jpg" }
                            }
                        }
                    }
                }

                Text { text: "Use somente imagens autorizadas para os testes."; color: "#64748B"; font.pixelSize: 10 }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        Layout.preferredWidth: 100; Layout.preferredHeight: 34; color: "transparent"; border.color: "#38BDF8"; radius: 3
                        Text { anchors.centerIn: parent; text: "CANCELAR"; color: "#38BDF8"; font.bold: true; font.pixelSize: 11 }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalAdicionar.visible = false }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 140; Layout.preferredHeight: 34; color: "#2DD4BF"; radius: 3
                        Text { anchors.centerIn: parent; text: "SALVAR CADASTRO"; color: "#0F172A"; font.bold: true; font.pixelSize: 11 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Pega o que digitou ou põe valor padrão e salva na lista
                                var nomeCad = addNome.text !== "" ? addNome.text : "Novo Suspeito"
                                var idadeCad = addIdade.text !== "" ? addIdade.text : "20"
                                var idNovo = (modeloCadastrados.count + 1).toString()

                                modeloCadastrados.append({
                                    idCad: idNovo,
                                    nome: nomeCad,
                                    idade: idadeCad,
                                    situacao: addSituacao.currentText,
                                    cadastro: "ATIVO",
                                    descricao: addDescricao.text
                                })

                                // Limpa tudo e fecha
                                addNome.text = ""
                                addIdade.text = ""
                                addDescricao.text = ""
                                addFotoPath.text = ""
                                modalAdicionar.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================
    // MODAL 2: GERENCIAR CADASTRADOS (Janela pop-up 2)
    // =========================================================
    Rectangle {
        id: modalGerenciar
        anchors.fill: parent
        color: "#B0000000"
        visible: false
        z: 9999

        property int indiceSelecionado: -1

        // Filtra a tabela de cadastrados conforme o ComboBox
        function aplicarFiltro() {
            modeloFiltrado.clear()
            var filtro = comboFiltro.currentText
            for (var i = 0; i < modeloCadastrados.count; i++) {
                var item = modeloCadastrados.get(i)
                if (filtro === "TODOS" || item.situacao === filtro) {
                    modeloFiltrado.append({
                        idCad: item.idCad,
                        nome: item.nome,
                        idade: item.idade,
                        situacao: item.situacao,
                        cadastro: item.cadastro,
                        descricao: item.descricao,
                        indexOriginal: i
                    })
                }
            }
            modalGerenciar.indiceSelecionado = -1
        }

        onVisibleChanged: {
            if (visible) aplicarFiltro()
        }

        MouseArea { anchors.fill: parent }

        Rectangle {
            width: 1080
            height: 580
            anchors.centerIn: parent
            color: "#0B101D"
            border.color: "#1E293B"
            border.width: 1
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Face-X — Gerenciar cadastrados"; color: "#94A3B8"; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"; color: "#94A3B8"; font.pixelSize: 14; font.bold: true
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalGerenciar.visible = false }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "GERENCIAR CADASTRADOS"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 16 }
                    Text { text: "Edite os dados ou desative temporariamente um cadastro do banco de dados."; color: "#64748B"; font.pixelSize: 11 }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 16

                    // Tabela da esquerda (Lista de cadastrados bem espaçada)
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        Text { text: "PESSOAS CADASTRADAS"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                        RowLayout {
                            spacing: 8
                            Text { text: "Exibir:"; color: "#94A3B8"; font.pixelSize: 11 }
                            ComboBox {
                                id: comboFiltro
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 28
                                model: ["TODOS", "SUSPEITO", "PROCURADO"]
                                background: Rectangle { color: "#FFFFFF"; radius: 3 }
                                onCurrentTextChanged: modalGerenciar.aplicarFiltro()
                            }
                        }

                        ListModel { id: modeloFiltrado }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "#FFFFFF"
                            border.color: "#CBD5E1"
                            radius: 4

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0

                                // Titulo das colunas
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 34
                                    color: "#E2E8F0"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 12; anchors.rightMargin: 12
                                        spacing: 10

                                        Text { text: "ID"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 35 }
                                        Text { text: "Nome"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                                        Text { text: "Idade"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 45 }
                                        Text { text: "Situação"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                        Text { text: "Cadastro"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 80 }
                                    }
                                }

                                // Linhas da tabela
                                ListView {
                                    id: listCadastrados
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    model: modeloFiltrado

                                    delegate: Rectangle {
                                        width: listCadastrados.width
                                        height: 36
                                        color: modalGerenciar.indiceSelecionado === index ? "#38BDF8" : (index % 2 === 0 ? "#FFFFFF" : "#F8FAFC")

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 12; anchors.rightMargin: 12
                                            spacing: 10

                                            Text { text: model.idCad; color: modalGerenciar.indiceSelecionado === index ? "#FFFFFF" : "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 35 }
                                            Text { text: model.nome; color: modalGerenciar.indiceSelecionado === index ? "#FFFFFF" : "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                                            Text { text: model.idade; color: modalGerenciar.indiceSelecionado === index ? "#FFFFFF" : "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 45 }
                                            Text { text: model.situacao; color: modalGerenciar.indiceSelecionado === index ? "#FFFFFF" : "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                            Text {
                                                text: model.cadastro
                                                color: modalGerenciar.indiceSelecionado === index ? "#FFFFFF" : (model.cadastro === "ATIVO" ? "#059669" : "#DC2626")
                                                font.bold: true
                                                font.pixelSize: 11
                                                Layout.preferredWidth: 80
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // Preenche os campos da direita ao clicar na linha
                                                modalGerenciar.indiceSelecionado = index
                                                editNome.text = model.nome
                                                editIdade.text = model.idade
                                                editSituacao.currentIndex = model.situacao === "SUSPEITO" ? 0 : 1
                                                editDescricao.text = model.descricao
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Form da direita pra editar o item selecionado
                    ColumnLayout {
                        Layout.preferredWidth: 260
                        Layout.fillHeight: true
                        spacing: 10

                        Text { text: "DADOS DO CADASTRO"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 11 }

                        ColumnLayout {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: "Nome completo"; color: "#94A3B8"; font.pixelSize: 10 }
                            TextField { id: editNome; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; font.pixelSize: 11; background: Rectangle { color: "#1C2541"; radius: 3; border.color: "#334155" } }
                        }

                        ColumnLayout {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: "Idade"; color: "#94A3B8"; font.pixelSize: 10 }
                            TextField { id: editIdade; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; font.pixelSize: 11; background: Rectangle { color: "#1C2541"; radius: 3; border.color: "#334155" } }
                        }

                        ColumnLayout {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: "Situação"; color: "#94A3B8"; font.pixelSize: 10 }
                            ComboBox {
                                id: editSituacao
                                Layout.fillWidth: true; Layout.preferredHeight: 34
                                model: ["SUSPEITO", "PROCURADO"]
                                background: Rectangle { color: "#FFFFFF"; radius: 3 }
                            }
                        }

                        ColumnLayout {
                            spacing: 4; Layout.fillWidth: true
                            Text { text: "Descrição / ocorrência associada"; color: "#94A3B8"; font.pixelSize: 10 }
                            TextField { id: editDescricao; Layout.fillWidth: true; Layout.preferredHeight: 34; color: "#FFFFFF"; font.pixelSize: 11; background: Rectangle { color: "#1C2541"; radius: 3; border.color: "#334155" } }
                        }

                        Item { Layout.fillHeight: true }

                        // Botões de salvar, desativar ou excluir
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 36; color: "#38BDF8"; radius: 3
                                Text { anchors.centerIn: parent; text: "SALVAR ALTERAÇÕES"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modalGerenciar.indiceSelecionado >= 0) {
                                            var itemFiltrado = modeloFiltrado.get(modalGerenciar.indiceSelecionado)
                                            var indexOrig = itemFiltrado.indexOriginal

                                            modeloCadastrados.setProperty(indexOrig, "nome", editNome.text)
                                            modeloCadastrados.setProperty(indexOrig, "idade", editIdade.text)
                                            modeloCadastrados.setProperty(indexOrig, "situacao", editSituacao.currentText)
                                            modeloCadastrados.setProperty(indexOrig, "descricao", editDescricao.text)

                                            modalGerenciar.aplicarFiltro()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 36; color: "#2DD4BF"; radius: 3
                                Text { anchors.centerIn: parent; text: "DESATIVAR / REATIVAR"; color: "#0F172A"; font.bold: true; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modalGerenciar.indiceSelecionado >= 0) {
                                            var itemFiltrado = modeloFiltrado.get(modalGerenciar.indiceSelecionado)
                                            var indexOrig = itemFiltrado.indexOriginal
                                            var novoStatus = itemFiltrado.cadastro === "ATIVO" ? "INATIVO" : "ATIVO"

                                            modeloCadastrados.setProperty(indexOrig, "cadastro", novoStatus)
                                            modalGerenciar.aplicarFiltro()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 36; color: "#EF4444"; radius: 3
                                Text { anchors.centerIn: parent; text: "EXCLUIR DEFINITIVAMENTE"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modalGerenciar.indiceSelecionado >= 0) {
                                            var itemFiltrado = modeloFiltrado.get(modalGerenciar.indiceSelecionado)
                                            var indexOrig = itemFiltrado.indexOriginal

                                            modeloCadastrados.remove(indexOrig)
                                            editNome.text = ""
                                            editIdade.text = ""
                                            editDescricao.text = ""
                                            modalGerenciar.aplicarFiltro()
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: 36; color: "#1E293B"; border.color: "#334155"; radius: 3
                                Text { anchors.centerIn: parent; text: "ATUALIZAR LISTA"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modalGerenciar.aplicarFiltro()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================
    // MODAL 3: HISTÓRICO DE OCORRÊNCIAS (Janela pop-up 3)
    // =========================================================
    Rectangle {
        id: modalHistorico
        anchors.fill: parent
        color: "#B0000000"
        visible: false
        z: 9999

        // Filtra o histórico por status e por nome/câmera pesquisados
        function aplicarFiltroHistorico() {
            modeloHistoricoFiltrado.clear()
            var st = comboStatusHistorico.currentText
            var busca = campoBuscaPessoaCam.text.toLowerCase()

            for (var i = 0; i < modeloHistorico.count; i++) {
                var item = modeloHistorico.get(i)
                var atendeStatus = (st === "TODOS" || item.status === st)
                var atendeBusca = (busca === "" || item.pessoa.toLowerCase().indexOf(busca) !== -1 || item.camera.toLowerCase().indexOf(busca) !== -1)

                if (atendeStatus && atendeBusca) {
                    modeloHistoricoFiltrado.append({
                        idOcorrencia: item.idOcorrencia,
                        dataHora: item.dataHora,
                        pessoa: item.pessoa,
                        camera: item.camera,
                        similaridade: item.similaridade,
                        status: item.status
                    })
                }
            }
        }

        onVisibleChanged: {
            if (visible) aplicarFiltroHistorico()
        }

        MouseArea { anchors.fill: parent }

        Rectangle {
            width: 1000
            height: 580
            anchors.centerIn: parent
            color: "#0B101D"
            border.color: "#1E293B"
            border.width: 1
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "FACE-X — Histórico de ocorrências"; color: "#94A3B8"; font.pixelSize: 11 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"; color: "#94A3B8"; font.pixelSize: 14; font.bold: true
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modalHistorico.visible = false }
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "HISTÓRICO DE OCORRÊNCIAS"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 16 }
                    Text { text: "Consulte ocorrências pendentes, confirmadas e descartadas."; color: "#64748B"; font.pixelSize: 11 }
                }

                // Barra de busca do histórico
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    RowLayout {
                        spacing: 8
                        Text { text: "Status:"; color: "#94A3B8"; font.pixelSize: 11 }
                        ComboBox {
                            id: comboStatusHistorico
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 30
                            model: ["TODOS", "PENDING", "CONFIRMED", "DISCARDED"]
                            background: Rectangle { color: "#FFFFFF"; radius: 3 }
                            onCurrentTextChanged: modalHistorico.aplicarFiltroHistorico()
                        }
                    }

                    RowLayout {
                        spacing: 8
                        Text { text: "Pessoa ou câmera:"; color: "#94A3B8"; font.pixelSize: 11 }
                        TextField {
                            id: campoBuscaPessoaCam
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: 30
                            color: "#FFFFFF"
                            placeholderTextColor: "#94A3B8"
                            font.pixelSize: 11
                            placeholderText: "Digite um nome ou câmera..."
                            background: Rectangle { color: "#1C2541"; radius: 3; border.color: "#334155" }
                            onTextChanged: modalHistorico.aplicarFiltroHistorico()
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                ListModel { id: modeloHistoricoFiltrado }

                // Tabela de registros do histórico
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#FFFFFF"
                    border.color: "#CBD5E1"
                    radius: 4

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            color: "#E2E8F0"

                            GridLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12; anchors.rightMargin: 12
                                columns: 6

                                Text { text: "ID"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 40 }
                                Text { text: "Data e hora"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 160 }
                                Text { text: "Pessoa"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                                Text { text: "Câmera"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                Text { text: "Similaridade"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                Text { text: "Status"; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                            }
                        }

                        ListView {
                            id: listHistorico
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: modeloHistoricoFiltrado

                            delegate: Rectangle {
                                width: listHistorico.width
                                height: 32
                                color: index % 2 === 0 ? "#FFFFFF" : "#F8FAFC"

                                GridLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12; anchors.rightMargin: 12
                                    columns: 6

                                    Text { text: model.idOcorrencia; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 40 }
                                    Text { text: model.dataHora; color: "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 160 }
                                    Text { text: model.pessoa; color: "#0F172A"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: model.camera; color: "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                    Text { text: model.similaridade; color: "#0F172A"; font.pixelSize: 11; Layout.preferredWidth: 90 }
                                    Text {
                                        text: model.status
                                        color: model.status === "CONFIRMED" ? "#059669" : (model.status === "PENDING" ? "#D97706" : "#DC2626")
                                        font.bold: true
                                        font.pixelSize: 11
                                        Layout.preferredWidth: 90
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: modeloHistoricoFiltrado.count + " ocorrência(s) encontrada(s)."
                        color: "#94A3B8"
                        font.pixelSize: 11
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 34
                        color: "#38BDF8"
                        radius: 3

                        Text { anchors.centerIn: parent; text: "ATUALIZAR HISTÓRICO"; color: "#FFFFFF"; font.bold: true; font.pixelSize: 10 }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modalHistorico.aplicarFiltroHistorico()
                        }
                    }
                }
            }
        }
    }
}
