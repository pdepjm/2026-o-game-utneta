import wollok.game.*
import zombies.*
import jardin.*
import reloj.*


class Planta {
  var property position
  var vida = 100
  const property nombre
  const msEntreAcciones = 2000  
  const tarea = new Tarea(milisegundos = msEntreAcciones, accion = { self.accion() })

  method image() = nombre + ".png"

  method iniciar() {
    reloj.agregar(tarea)
  }

  method accion()   // abstracto: cada planta decide qué hace

  
  method recibirImpacto(proyectil) {}

  method recibirDanio(cantidad) {
    vida -= cantidad
    if (vida <= 0) {
      self.morir()
    }
  }

  // deja de disparar y libera la celda para plantar otra
  method morir() {
    tarea.terminar()
    game.removeVisual(self)
    jardin.sacarPlanta(self)
  }
}


class Lanzador inherits Planta {
  method crearProyectil(posicion)   // abstracto: cada lanzador decide qué proyectil crea

  method lanzar(posicion) {
    const proyectil = self.crearProyectil(posicion)
    game.addVisual(proyectil)
    proyectil.iniciarMovimiento()
  }

  method disparar() {
    self.lanzar(position.right(1))
  }

  override method accion() {
    if (generadorDeZombies.hayZombiesEnCarril(position.y())) {   // solo dispara si hay zombies en SU carril
      self.disparar()
    }
  }
}

class Lanzaguisantes inherits Lanzador(nombre = "lanzaguisantes") {
  override method crearProyectil(posicion) = new Bolita(position = posicion)
}

class LanzaguisantesHielo inherits Lanzador(nombre = "lanzaguisanteDeHielo") {
  override method crearProyectil(posicion) = new BolitaHielo(position = posicion)
}

class LanzaguisantesDoble inherits Lanzaguisantes(nombre = "lanzaguisantesDoble", msEntreAcciones = 3000) {
  // dispara una bolita adelante y otra pegada atrás (una celda detrás de la primera)
  override method disparar() {
    super()
    self.lanzar(position)
  }
}



class Bolita {
  var property position
  var viva = true
  const tarea = new Tarea(milisegundos = 400, accion = { self.mover() })

  method nombre() = "guisante"
  method danio() = 25
  method image() = self.nombre() + ".png"
  method estaViva() = viva

  method iniciarMovimiento() {
    reloj.agregar(tarea)
  }

  // antes de avanzar se fija si un zombie se metió en su celda, y después en la celda nueva
  method mover() {
    self.chocar()
    if (viva) {
      position = position.right(1)
      self.chocar()
    }
    if (position.x() >= game.width()) {
      self.morir()
    }
  }

  // le avisa a todo lo que está en su celda (solo los zombies reaccionan)
  method chocar() {
    game.colliders(self).forEach({ otro => otro.recibirImpacto(self) })
  }

  
  method impactar(zombie) {
    zombie.recibirDanio(self.danio())
  }

  // dos bolitas en la misma celda no se afectan (Polimorfismo)
  method recibirImpacto(otraBolita) {}

  method morir() {
    if (viva) {
      viva = false
      tarea.terminar()
      game.removeVisual(self)
    }
  }
}

class BolitaHielo inherits Bolita {
  override method nombre() = "guisanteDeHielo"

  override method impactar(zombie) {
    zombie.ralentizar()
    super(zombie)
  }
}
