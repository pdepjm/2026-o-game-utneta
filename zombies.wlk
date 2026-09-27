// zombies.wlk
import wollok.game.*

class Zombie {
  var property nombre // para poder ponerle una imagen al crearlos
  var property position // posicion de cada zombie
  var property vida // cada zombie tiene su vida 
  var property velocidad // los zombies tienen velocidad propia (a mayor numero el zombie es más lento)
  const property danio = 10 // cada uno hace un danio distinto
  
  const tickMovimiento = game.tick(velocidad*1000, {self.mover()}, false) // el movimiento depende de la velocidad de cada zombie

  method image() = nombre + ".png"
  method iniciar() {  tickMovimiento.start()  } // para iniciar el movimiento de los zombies a la hora de crearlos
  
  method mover() {
    position = position.left(1) // todos los zombies avanzan la misma cantidad de casillas
    if (self.position().x() <= 0) {  // si su posicion paso la del tablero lo elimina
      generadorDeZombies.eliminarZombie(self)
    }
  }

  method recibirDanio(cantidad) {
    vida -= cantidad
    if (vida <= 0) {
      generadorDeZombies.eliminarZombie(self)
      self.morir()
    }
  }

  method recibirRalentizacion(cantidad) {
    velocidad -= cantidad
  }

  method morir() {
    game.removeVisual(self)
    game.removeTickEvent(tickMovimiento)
  }
}

// zombies.wlk (seguimos en el mismo archivo)
object generadorDeZombies {
  const carril = 2  // fila fija por ahora
  var property zombiesActivos = []

  method generar() {
    const nuevoZombie = new Zombie(nombre = "zombie", velocidad = 1, position = game.at(game.width() - 1, carril), vida=100)
    nuevoZombie.iniciar()
    zombiesActivos.add(nuevoZombie)
    game.addVisual(nuevoZombie)
  }

  method hayZombies() = !zombiesActivos.isEmpty()

  method eliminarZombie(unZombie) {
    zombiesActivos.remove(unZombie)
  }
}