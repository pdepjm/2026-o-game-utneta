import plantas.*
import zombies.*
import wollok.game.*

object jardin {
  const property carriles = [1, 2, 3]   // filas (y) por las que avanzan los zombies
  const plantasActivas = []
  var property terminada = false

  method plantar(unaPlanta) {
    plantasActivas.add(unaPlanta)
    game.addVisual(unaPlanta)
    unaPlanta.iniciar()
  }

  // arma el jardín inicial: una planta distinta en cada carril, en la primera columna
  method iniciar() {
    self.plantar(new Lanzaguisantes(position = game.at(0, carriles.get(0))))
    self.plantar(new LanzaguisantesHielo(position = game.at(0, carriles.get(1))))
    self.plantar(new LanzaguisantesDoble(position = game.at(0, carriles.get(2))))
  }

  method ganar() {
    self.terminar()
    cartelFinal.nombre("ganaste")
  }

  method perder() {
    self.terminar()
    cartelFinal.nombre("perdiste")
  }

  method terminar() {
    if (!terminada) {     // varios zombies pueden llegar a la vez
      terminada = true
      game.clear()        // saca todos los visuales y frena todos los ticks/colisiones
      game.addVisual(cartelFinal)
    }
  }
}
object cartelFinal {
  method position() = game.center()
  var property nombre = ""
  method image() = nombre +".png"
}
