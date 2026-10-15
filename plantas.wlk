import wollok.game.*
import zombies.*
import jardin.*   

class Planta {
  var property position // posicion de la planta
  var property vida // vida de la planta
  var property velocidad  // tiempo en realizar su accion caracteristica
  var property nombre // nombre de la planta (utilizado para agregarle una imagen)
  const accion // accion a realizar
  method image() = nombre + ".png"  // imagen
  const tickAccion = game.tick(velocidad*1000, {accion.apply(self)} , false) // tiempo de cada planta en realizar su accion (depende unicamente de su velocidad)
  
  method iniciar() { tickAccion.start() } // utilizado al momento de crear la planta para inicializarla

  method recibirDanio(danio_recibido){  // para recibir daño de los zombies
    vida -= danio_recibido
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


class Girasol inherits Planta {

  override method hacerEfecto{
    cont unSol = new Sol (position = position)
    game.addVisual(unSol)
  }
}

method plantarGirasol (position){
  conts miGirasol = new Girasol(
    position = position,
    vida = 80,
    velocidad = 5,
    nombre = "Girasol"
  )
  game.addVisual(miGirasol)
  miGirasol.iniciar()
}

class Nuez inherits Planta {
  conts nuez = new Nuez(
    vida = 1000
  )
  override method hacerEfecto (){
    //solo aguanta golpes
  }
}
  method morir() {
    game.removeTickEvent(tickMovimiento)
    game.removeVisual(self)
  }
}
