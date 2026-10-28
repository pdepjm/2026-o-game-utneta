import wollok.game.*
import jardin.*
import zombies.*
import vivero.*
import soles.*
import reloj.*

// ============================================================
// JUEGO: sabe en qué estado está la partida y le delega todo
// ============================================================
object juego {
  var estado = menuInicio

  method iniciar() {
    jardin.prepararTablero()
    self.cambiarEstado(menuInicio)
  }

  method cambiarEstado(nuevoEstado) {
    estado = nuevoEstado
    reloj.detener()              // lo que quedaba pendiente de antes no se hace más
    game.clear()                 // saca visuales y ticks, pero también el teclado y el click...
    self.configurarControles()   // ...por eso los volvemos a registrar cada vez
    estado.empezar()
  }

  method configurarControles() {
    game.onClickDo({ posicion => estado.click(posicion) })
    // una tecla por cada planta del vivero: 1, 2, 3...
    vivero.opciones().forEach({ opcion =>
      keyboard.num(opcion.numero()).onPressDo({ estado.elegir(opcion) })
    })
    keyboard.p().onPressDo({ estado.apretarPausa() })
  }

  // la pausa no hace game.clear(): el jardín queda como está y el menú de pausa va encima
  method pausar() {
    estado = pausa
    pausa.empezar()
  }

  method continuar() {
    pausa.terminar()
    estado = jugando
  }

  method ganar() {
    estado.ganar()
  }

  method perder() {
    estado.perder()
  }
}

// ============================================================
// ESTADOS DEL JUEGO: lo que un estado no redefine, no hace nada
// ============================================================
class EstadoDelJuego {
  method empezar()   // abstracto: qué pasa al entrar al estado

  method click(posicion) {}
  method elegir(opcion) {}
  method apretarPausa() {}
  method ganar() {}
  method perder() {}
}

object jugando inherits EstadoDelJuego {
  override method empezar() {
    reloj.iniciar()
    jardin.reiniciar()               // todo vuelve a como estaba al principio
    generadorDeZombies.reiniciar()
    vivero.reiniciar()
    vivero.mostrarPanel()
    game.addVisual(botonPausa)
    soles.iniciar()
    generadorDeZombies.empezarOleada()
  }

  override method click(posicion) {
    if (botonPausa.position() == posicion) {
      juego.pausar()
    } else {
      self.plantarEn(posicion)
    }
  }

  // si no se puede plantar, el problema aparece en un cartel grande
  // (el globito de Wollok es muy chiquito y no se lee)
  method plantarEn(posicion) {
    try {
      vivero.plantarEn(posicion)
    } catch problema : NoSePuedePlantar {
      cartelDeAviso.mostrar(problema.cartel())
    }
  }

  override method elegir(opcion) {
    vivero.elegida(opcion)
  }

  override method apretarPausa() {
    juego.pausar()
  }

  override method ganar() {
    juego.cambiarEstado(ganaste)
  }

  override method perder() {
    juego.cambiarEstado(perdiste)
  }
}

// El menú, los carteles de ganaste y perdiste y la pausa son iguales:
// una imagen grande y sus botones
class Pantalla inherits EstadoDelJuego {
  const property image
  const botones
  const property position = game.at(2, 2)

  override method empezar() {
    game.addVisual(self)
    botones.forEach({ boton => game.addVisual(boton) })
  }

  override method click(posicion) {
    botones.forEach({ boton => boton.clickEn(posicion) })
  }
}

object menuInicio inherits Pantalla(image = "menu.png", botones = [botonOk]) {}

object ganaste inherits Pantalla(image = "ganaste.png", botones = [botonReintentar]) {}

object perdiste inherits Pantalla(image = "perdiste.png", botones = [botonReintentar]) {}

// La pausa va encima del jardín sin borrarlo (oscurece todo el tablero)
// y frena el reloj, así todo se queda quieto hasta que sigas
object pausa inherits Pantalla(image = "pausa.png", botones = [botonContinuar, botonReiniciar], position = game.at(0, 0)) {
  override method empezar() {
    reloj.pausar()
    super()
  }

  method terminar() {
    game.removeVisual(self)
    botones.forEach({ boton => game.removeVisual(boton) })
    reloj.continuar()
  }

  override method apretarPausa() {
    juego.continuar()
  }
}

// ============================================================
// BOTONES: ocupan 2 celdas. Si no dicen otra cosa, empiezan una
// partida nueva.
// ============================================================
class Boton {
  const property image
  const property position = game.at(5, 1)

  method clickEn(posicion) {
    if (self.contiene(posicion)) {
      self.apretar()
    }
  }

  method apretar() {
    juego.cambiarEstado(jugando)
  }

  method contiene(posicion) = posicion.y() == self.position().y() and posicion.x().between(self.position().x(), self.position().x() + 1)
}

object botonOk inherits Boton(image = "botonOk.png") {}

object botonReintentar inherits Boton(image = "botonReintentar.png") {}

object botonContinuar inherits Boton(image = "botonContinuar.png", position = game.at(4, 2)) {
  override method apretar() {
    juego.continuar()
  }
}

object botonReiniciar inherits Boton(image = "botonReiniciar.png", position = game.at(6, 2)) {}

// el botón de la barra de arriba para pausar (con la P también se puede)
object botonPausa {
  const property position = game.at(11, jardin.filaDelPanel())
  method image() = "botonPausa.png"
}
