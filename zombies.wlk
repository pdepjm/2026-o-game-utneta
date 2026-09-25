// zombies.wlk
import wollok.game.*

class Zombie {
  var property position
  var vida = 100
  const velocidad = 0.5
  const danioQueHace = 10

  method text() = "Z"

  method mover() {
    position = position.left(velocidad)
  }

  method llegoAlFinal() = position.x() <= 0

  method recibirDanio(cantidad) {
    vida = vida - cantidad
    if (vida <= 0) {
      self.morir()
    }
  }

  method estaMuerto() = vida <= 0

  method morir() {
    game.removeVisual(self)
  }
}

// zombies.wlk (seguimos en el mismo archivo)
object generadorDeZombies {
  const carril = 2  // fila fija por ahora
  var property zombiesActivos = []

  method generar() {
    const nuevoZombie = new Zombie(position = game.at(game.width() - 1, carril))
    zombiesActivos.add(nuevoZombie)
    game.addVisual(nuevoZombie)
  }

  method moverTodos() {
    zombiesActivos.forEach { z => z.mover() }
    zombiesActivos = zombiesActivos.filter { z => !z.llegoAlFinal() }
  }

  method hayZombies() = !zombiesActivos.isEmpty()

    method eliminarZombie(unZombie) {
    zombiesActivos.remove(unZombie)
    unZombie.morir()
  }
}