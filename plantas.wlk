import wollok.game.*
import zombies.*

class Planta {
  var property position
  method text() = "P"

  method disparar() {
    if (generadorDeZombies.hayZombies()) {
      jardin.agregarBolita(new Bolita(position = position.right(1)))
    }
  }
}

class Bolita {
  var property position
  const velocidad = 1
  const danio = 25
  var viva = true

  method text() = "o"
  method danio() = danio
  method estaViva() = viva

  method mover() {
    position = position.right(velocidad)
    if (position.x() >= game.width()) {
      self.morir()
    }
  }

  method morir() {
    viva = false
    game.removeVisual(self)
  }
}

// plantas.wlk
object jardin {
  var property plantasActivas = []
  var property bolitasActivas = []

  method plantar() {
    const nuevaPlanta = new Planta(position = game.at(0, 2))
    plantasActivas.add(nuevaPlanta)
    game.addVisual(nuevaPlanta)
  }

  method dispararTodas() {
    plantasActivas.forEach { p => p.disparar() }
  }

  method agregarBolita(unaBolita) {
    bolitasActivas.add(unaBolita)
    game.addVisual(unaBolita)
  }

  method moverBolitas() {
    bolitasActivas.forEach { b => b.mover() }
    self.chequearColisiones()
    bolitasActivas = bolitasActivas.filter { b => b.estaViva() }
  }

  method chequearColisiones() {
    bolitasActivas.forEach { b =>
      generadorDeZombies.zombiesActivos().forEach { z =>
        if (b.estaViva() and z.position() == b.position()) {
          z.recibirDanio(b.danio())
          b.morir()
        }
      }
    }
  }
}