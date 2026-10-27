import plantas.*
import zombies.*
import wollok.game.*

object jardin {
  var property pausado = false
  const property carriles = [1, 2, 3]   // filas (y) por las que avanzan los zombies
  const plantasActivas = []

  method plantar(unaPlanta) {
    plantasActivas.add(unaPlanta)
    game.addVisual(unaPlanta)
    unaPlanta.iniciar()
  }

  method eliminarPlanta(unaPlanta) {
    plantasActivas.remove(unaPlanta)
  }

  // arma el jardín inicial: una planta distinta en cada carril, en la primera columna
  method iniciar() {
    self.plantar(new Lanzaguisantes(position = game.at(0, carriles.get(0))))
    self.plantar(new LanzaguisantesHielo(position = game.at(0, carriles.get(1))))
    self.plantar(new LanzaguisantesDoble(position = game.at(0, carriles.get(2))))
  }

  method finalizar(motivo) {        
    self.pausar()
    game.addVisual(motivo)
  }
}
object victoria {
  method position() = game.center()
  method image() = "ganaste.png"
}
object derrota {
  method position() = game.center()
  method image() = "perdiste.png"
}