import wollok.game.*
import zombies.*
import jardin.*   

class Planta {
  var property position // posicion de la planta
  var property vida // vida de la planta
  var property velocidad  // tiempo en realizar su accion caracteristica
  var property nombre // nombre de la planta (utilizado para agregarle una imagen)
  method accion() {} // accion a realizar
  method image() = nombre + ".png"  // imagen
  var tickAccion =  null
  
  method iniciar() { 
    game.tick(velocidad*1000, {accion.apply(self)} , false) // tiempo de cada planta en realizar su accion (depende unicamente de su velocidad)
    tickAccion.start() 
    } // utilizado al momento de crear la planta para inicializarla

  method recibirDanio(danio_recibido){  // para recibir daño de los zombies
    vida -= danio_recibido
    if (vida <= 0) {
      self.morir()
    }
  }

  method morir(){
    if (tickAccion != null) {
      game.removeTickEvent(tickAccion)
    }
    game.removeVisual(self)
  }
  
  method disparar() { // accion posible de la planta
    if (generadorDeZombies.hayZombies()) { // si hay zombie entonces la planta dispara
        const nuevoProyectil = new Bolita(position = position.right(1), nombre = "guisante") // creamos el proyectil
        game.addVisual(nuevoProyectil) // agregamos la imagen del proyectil
        game.onCollideDo(nuevoProyectil, {objeto => 
          objeto.recibirDanio(nuevoProyectil.danio())
          nuevoProyectil.morir()
        })
        nuevoProyectil.iniciarMovimiento()  // inicializamos el movimiento del proyectil
      }
  }
}

class Bolita {
  var property nombre // nombre del proyectil para poder agregarle su imagen
  var property position // posicion del proyectil
  const property danio = 25 // daño realizado por el proyectil
  const property ralentizacion = 1 // cantidad de ralentizacion que realiza el proyectil al zombie
  const tickMovimiento = game.tick(600, {self.mover()}, false)
  method image() = nombre + ".png"

  method iniciarMovimiento(){
    tickMovimiento.start()
  }

 method mover() {
      position = position.right(1)
      if (position.x() >= game.width()) {
        self.morir()
      }
  }

  method morir() {
    game.removeTickEvent(tickMovimiento)
    game.removeVisual(self)
  }
}

class Girasol inherits Planta {

  override method accion() {
    const unSol = new Sol (position = position)
    game.addVisual(unSol)
  }

}
method plantarGirasol (position) {
  const miGirasol = new Girasol(
    position = position,
    vida = 80,
    velocidad = 5,
    nombre = "Girasol"
  )
  game.addVisual(miGirasol)
  miGirasol.iniciar()
}

class Nuez inherits Planta {
 //no tiene movimiento periódico
}

method plantarNuez(position) {
  const miNuez = new Nuez(
    position = position,
    vida = 1000,
    velocidad = 1,
    nombre = "Nuez"
  )
  game.addVisual(miNuez) //para que se vea en el tablero
  miNuez.iniciar()
}