//
//  ViewController.swift
//  Buscaminas
//
//  Created by Usuario on 26/09/24.
//
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    //-----------------------------CUADRICULA-----------------------------//
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //-------------------------------BOTONES-------------------------------//
    
    @IBOutlet weak var botonBandera: UIButton!
    @IBOutlet weak var botonVoltear: UIButton!
    @IBOutlet weak var botonDuda: UIButton!
    @IBOutlet weak var botonRevelar: UIButton!
    @IBOutlet weak var botonRestart: UIButton!
    
    @IBOutlet weak var casillaInfo: UITextField!
    @IBOutlet weak var temporizador: UILabel!
    @IBOutlet weak var banderasColocadas: UILabel!
    
    //------------------------------VARIABLES------------------------------//
    
    enum EstadoCelda {
        case seleccionada, minada, banderada, conDuda, volteada
    }
    
    struct Casilla {
        var seleccionada: Bool
        var minada: Bool
        var bandereada: Bool
        var conDuda: Bool
        var volteada: Bool
        var minasVecinas: Int
    }
    
    let tamanoTablero = 10
    let numeroDeMinas = 15

    var tablero: [[Casilla]] = []
    var almacenSelecciones: IndexPath?
    var contadorDeBanderas: Int!
    
    //DESEMPAQUETAR CASILLA SELECCIONADA
    
    var numeroCasillaSeleccionada: Int? {
        guard let indexPath = almacenSelecciones else {
            return nil
        }
        return indexPath.row + 1
    }
    

    //-----------------------------PRECARGAR JUEGO-----------------------------//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inicializarTablero()
        crearTablero()
        configurarLayout()
        contadorDeBanderas = numeroDeMinas
        actualizarContadorBanderas()
    }
    
    //-----------------------------INICIALIZAR VARIABLES----------------------------//
    
    func inicializarTablero() {
        JuegoActivado()
        tablero = Array(repeating: Array(repeating: Casilla(seleccionada: false, minada: false, bandereada: false, conDuda: false, volteada: false, minasVecinas: 0), count: tamanoTablero), count: tamanoTablero)
        
        // Crear un array de tamaño tamanoTablero, que contiene elementos que se repiten.
    }
    
    //-----------------------------DETECTAR CASILLA SELECCIONADA-----------------------------//
     
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        almacenSelecciones = indexPath
        collectionView.reloadItems(at: [indexPath]) // Para resaltar la celda seleccionada
        casillaInfo.text = "Casilla seleccionada: \(indexPath.row + 1)"
        botonRestart.setTitle("🫣", for: .normal)
    }
    
    //-----------------------------CONFIGURAR TABLERO-----------------------------//

    func configurarLayout() {
        let layout = UICollectionViewFlowLayout()
        let casillasPorFila: CGFloat = 10
        let margen: CGFloat = 10
        let margenHorizontal: CGFloat = 32
        let margenTotal = margen * (casillasPorFila - 1)
        let anchuraDisponible = CGFloat(collectionView.frame.width) - margenHorizontal - margenTotal
        let anchuraCasilla = anchuraDisponible / casillasPorFila
        
        layout.itemSize = CGSize(width: anchuraCasilla, height: anchuraCasilla)
        layout.minimumLineSpacing = margen
        layout.minimumInteritemSpacing = margen
        collectionView.collectionViewLayout = layout
    }
    
    
    //-----------------------------SETEAR MINAS-----------------------------//

    func crearTablero() {
        botonRestart.setTitle("😃", for: .normal)
        casillaInfo.textColor = .black
        var minasEnTablero = 0
        
        while minasEnTablero < numeroDeMinas {
            let minaEnFila = Int.random(in: 0..<tamanoTablero)
            let minaEnCol = Int.random(in: 0..<tamanoTablero)
            
            if !tablero[minaEnFila][minaEnCol].minada {
                tablero[minaEnFila][minaEnCol].minada = true
                minasEnTablero += 1
            }
        }
    
    // Recorre todo el tablero para cada casilla que no contiene una mina y le asigna el número de minas vecinas
        
        for fila in 0..<tamanoTablero {
            for col in 0..<tamanoTablero {
                if !tablero[fila][col].minada {
                    tablero[fila][col].minasVecinas = contarMinasVecinas(fila: fila, col: col)
                }
            }
        }
    }
    
    //-----------------------------CONTADOR DE MINAS VECINAS-----------------------------//

    func contarMinasVecinas(fila: Int, col: Int) -> Int {
        var contadorMinas = 0
        for i in max(0, fila - 1)...min(tamanoTablero - 1, fila + 1) {
            for j in max(0, col - 1)...min(tamanoTablero - 1, col + 1) {
                if tablero[i][j].minada {
                    contadorMinas += 1
                }
            }
        }
        return contadorMinas
    }
    
    //-------------PARA VISUALIZAR ELELEMENTOS DEL TABLERO----------------//

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tamanoTablero * tamanoTablero
    }

    //------------------INTERACCIONES DEL USUARIO---------------------//

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "CeldaBuscaminas", for: indexPath) as! CeldaBuscaminas
        let fila = indexPath.row / tamanoTablero
        let col = indexPath.row % tamanoTablero
        let casillaTablero = tablero[fila][col]

        // Configurar la visualización de la celda
        
        if casillaTablero.volteada {
            celda.backgroundColor = UIColor.systemGreen
            if casillaTablero.minada {
                celda.label.text = "💣"
                celda.backgroundColor = UIColor.red
                JuegoDesactivado()
            } else if casillaTablero.minasVecinas > 0 {
                celda.label.text = "\(casillaTablero.minasVecinas)" // Número de minas vecinas
            } else {
                celda.label.text = "" // Celda vacía
            }
        } else if casillaTablero.bandereada {
            celda.backgroundColor = .orange
            celda.label.text = "🚩"

        } else if casillaTablero.conDuda {
            celda.backgroundColor = .yellow
            celda.label.text = "❓"

        } else {
            celda.label.text = "" // Texto vacío si no está revelada
            celda.backgroundColor = .systemGray2 // Color original
        }

        return celda
    }
    
    //--------------------CONTADOR DE TIEMPO--------------------//
    
    var timer: Timer?
    var segundosPasados: Int = 0
    
    @objc func actualizarTimer() {
        segundosPasados += 1
        temporizador.text = formatoTimer(segundos: segundosPasados)
    }
    
    
    func formatoTimer(segundos: Int) -> String {
        let minutos = segundos / 60
        let segundos = segundos % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }
    
    //-------------BOTON RESET----------------//

    @IBAction func resetearTablero(_ sender: UIButton) {
        view.isUserInteractionEnabled = true
        inicializarTablero()
        crearTablero()
        // Invalidar el temporizador actual si existe
        DesactivarTimer()
        
        // Restablecer el contador de tiempo a cero
        segundosPasados = 0
        actualizarTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTimer), userInfo: nil, repeats: true)

        
        contadorDeBanderas = numeroDeMinas
        actualizarContadorBanderas()
        casillaInfo.text = "Juego reiniciado"
        collectionView.reloadData()
    }
    
    


    //-------------BOTÓN MARCAR BANDERA ----------------//

    @IBAction func marcarBandera(_ sender: UIButton) {
        guard let indexPath = almacenSelecciones else {
            casillaInfo.text = "Por favor, selecciona una celda."
            return
        }
        
        let fila = indexPath.row / tamanoTablero
        let col = indexPath.row % tamanoTablero
        var casilla = tablero[fila][col]

        // Solo permite marcar banderas si la casilla no está volteada
        if !casilla.volteada {
            if casilla.bandereada {
                // Si la casilla ya tiene una bandera, quitar y aumentar el contador de banderas
                casilla.bandereada = false
                contadorDeBanderas += 1
                casillaInfo.text = "Bandera removida de: \(indexPath.row + 1)"
            } else if contadorDeBanderas > 0 {
                // Si hay banderas disponibles, colocar una bandera y reducir el contador
                casilla.bandereada = true
                contadorDeBanderas -= 1
                casillaInfo.text = "Bandera colocada en: \(indexPath.row + 1)"
            } else {
                // Si no hay banderas disponible
                casillaInfo.text = "No quedan banderas disponibles"
            }

            // Actualiza el tablero con el nuevo estado de la casilla
            tablero[fila][col] = casilla
            collectionView.reloadItems(at: [indexPath])
            
            // Actualiza el contador de banderas en la UI
            actualizarContadorBanderas()
        }
    }
    
    //-------------ACTUALIZAR CONTADOR---------------//

    func actualizarContadorBanderas() {
        banderasColocadas.text = "\(contadorDeBanderas!)"
    }
    
    //-------------BOTON ABRIR----------------//

    @IBAction func voltearCelda(_ sender: UIButton) {
        guard let indexPath = almacenSelecciones else {
            casillaInfo.text = "Por favor, selecciona una celda."
            return
        }

        let fila = indexPath.row / tamanoTablero
        let col = indexPath.row % tamanoTablero
        var casilla = tablero[fila][col]

        // Solo voltear si no está revelada
        if !casilla.volteada {
            casilla.volteada = true
            tablero[fila][col] = casilla
            casillaInfo.text = "Casilla volteada en: \(indexPath.row + 1)"

            // Recargar la celda en el tablero
            collectionView.reloadItems(at: [indexPath])
            
            //si es mina
            if casilla.minada {
                // PERDER JUEGO
                casillaInfo.text = "¡Juego perdido!"
                casillaInfo.textColor = .red
                botonRestart.setTitle("🤯", for: .normal)
                DesactivarTimer()
            } else {
                // Si no, verificar minas vecinas
                if casilla.minasVecinas == 0 {
                    abrirCasillasVecinas(fila: fila, col: col)
                }
                // Verificar si el juego se ha ganado
                juegoGanado()
            }
        }
    }

    //-------------BOTÓN MARCAR DUDA----------------//


    @IBAction func marcarDuda(_ sender: UIButton) {
        guard let indexPath = almacenSelecciones else {
            casillaInfo.text = "Por favor, selecciona una celda."
            return
        }

        let fila = indexPath.row / tamanoTablero
        let col = indexPath.row % tamanoTablero
        var casilla = tablero[fila][col]

        // Alternar estado de duda
        if !casilla.volteada {
            casilla.conDuda.toggle()
            tablero[fila][col] = casilla
            collectionView.reloadItems(at: [indexPath])
            
            casillaInfo.text = "Duda colocada en: \(indexPath.row + 1)"
        }
    }
    
    //-------------BOTON REVELAR BOMBAS----------------//

    @IBAction func revelarBombas(_ sender: UIButton) {
        for fila in 0..<tamanoTablero {
            for col in 0..<tamanoTablero {
                if tablero[fila][col].minada {
                    let indexPath = IndexPath(row: fila * tamanoTablero + col, section: 0)
                    if let celda = collectionView.cellForItem(at: indexPath) as? CeldaBuscaminas {
                        // Cambiar la apariencia visual de la celda sin alterar su estado interno
                        celda.label.text = "💣" // Mostrar la bomba
                        celda.backgroundColor = .red // Cambiar color
                    }
                }
            }
        }

        // Actualizar el mensaje para indicar que es "trampa"
        casillaInfo.text = "Tramposo..."
        botonRestart.setTitle("😒", for: .normal)
    }


    //-------------FUNCION RECURSIVA PARA VOLTEAR CASILLAS----------------//

    func abrirCasillasVecinas(fila: Int, col: Int) {
        // Iterar sobre las filas vecinas (de fila-1 a fila+1) asegurándose de no salir de los límites del tablero.
        for i in max(0, fila - 1)...min(tamanoTablero - 1, fila + 1) {
            // Iterar sobre las columnas vecinas (de col-1 a col+1) asegurándose de no salir de los límites del tablero.
            for j in max(0, col - 1)...min(tamanoTablero - 1, col + 1) {
                // Asegurarse de no volver a la casilla original (fila, col) al continuar el proceso.
                if !(i == fila && j == col) {
                    // Obtener la casilla vecina en la posición (i, j).
                    var casillaVecina = tablero[i][j]
                    
                    // Comprobar si la casilla vecina no ha sido volteada y no tiene mina.
                    if !casillaVecina.volteada && !casillaVecina.minada {
                        // Marcar la casilla vecina como volteada.
                        casillaVecina.volteada = true
                        
                        // Actualizar el tablero con la casilla modificada.
                        tablero[i][j] = casillaVecina

                        // Recargar la celda en la colección (actualizar la vista) para reflejar el cambio.
                        collectionView.reloadItems(at: [IndexPath(row: i * tamanoTablero + j, section: 0)])

                        // Si la casilla vecina recién volteada no tiene minas adyacentes (minasVecinas == 0),
                        // llamar recursivamente a abrirCasillasVecinas para abrir sus vecinas también.
                        if casillaVecina.minasVecinas == 0 {
                            abrirCasillasVecinas(fila: i, col: j)
                        }
                    }
                }
            }
        }
    }

    
    
    //-------------GANAR JUEGO----------------//

    func juegoGanado() {
        let celdasRestantes = tablero.flatMap { $0 }.filter { !$0.volteada && !$0.minada }
        
        if celdasRestantes.isEmpty {
            casillaInfo.text = "¡Juego ganado!"
            casillaInfo.textColor = .red
            botonRestart.setTitle("😎", for: .normal)
            DesactivarTimer()
            JuegoDesactivado()
        }
    }

    //ACTIVAR JUEGO
    
    func JuegoDesactivado () {
        segundosPasados = 0
        DesactivarTimer() // Asegúrate de que esto invalide el temporizador
        collectionView.isUserInteractionEnabled = false
        botonBandera.isUserInteractionEnabled = false
        botonVoltear.isUserInteractionEnabled = false
        botonDuda.isUserInteractionEnabled = false
        botonRevelar.isUserInteractionEnabled = false
    }
    
    //DESACTIVAR JUEGO
    func JuegoActivado() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTimer), userInfo: nil, repeats: true)
        }
        collectionView.isUserInteractionEnabled = true
        botonBandera.isUserInteractionEnabled = true
        botonVoltear.isUserInteractionEnabled = true
        botonDuda.isUserInteractionEnabled = true
        botonRevelar.isUserInteractionEnabled = true
    }
    
    
    func DesactivarTimer(){
        timer?.invalidate()
        timer = nil
    }
}

