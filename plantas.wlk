import wollok.game.*
import zombies.*
import jardin.*

class Planta {
  var property position
  var vida
  const property nombre
  const msEntreAcciones
  const idTik = "accionPlanta" + self.identity()

  method image() = nombre + ".png"

  method iniciar() {
    jardin.agregarTiks(idTik, msEntreAcciones, { bolita => bolita.accion() }, self)
  }

  method accion()   // abstracto: cada planta decide qué hace

  method recibirImpacto(proyectil) {} // las plantas ignoran las bolitas (polimorfismo con Zombie)

  method recibirDanio(cantidad) {
    vida -= cantidad
    if (vida <= 0) {
      self.morir()
    }
  }

  method morir() {
    jardin.eliminarTik(idTik)
    jardin.eliminarPlanta(self)
  }
  
}

// Plantas que disparan proyectiles por su carril
class Lanzador inherits Planta {
  method crearProyectil(posicion)   // abstracto: cada lanzador decide qué proyectil crea

  method lanzar(posicion) {
    const proyectil = self.crearProyectil(posicion)
    jardin.agregarProyectil(proyectil)
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

class Lanzaguisantes inherits Lanzador(nombre = "lanzaguisantes", vida = 100, msEntreAcciones = 2000) {
  override method crearProyectil(posicion) = new Bolita(position = posicion)
}

class LanzaguisantesHielo inherits Lanzador(nombre = "lanzaguisanteDeHielo", vida = 100, msEntreAcciones = 2000) {
  override method crearProyectil(posicion) = new BolitaHielo(position = posicion)
}

class LanzaguisantesDoble inherits Lanzador(nombre = "lanzaguisantes", vida = 100, msEntreAcciones = 3000) {  // TODO imagen propia: "lanzaguisantesDoble"
  override method crearProyectil(posicion) = new Bolita(position = posicion)

  // dispara una bolita adelante y otra pegada atrás (una celda detrás de la primera)
  override method disparar() {
    super()
    self.lanzar(position)
  }
}

// ============================================================
// PROYECTILES
// ============================================================

class Bolita {
  var property position
  var viva = true
  const idTik = "movimientoBolita" + self.identity()   // id único por bolita

  method nombre() = "guisante"
  method danio() = 25
  method image() = self.nombre() + ".png"
  method estaViva() = viva

  method iniciarMovimiento() {
    jardin.agregarTiks(idTik, 400, { bolita => bolita.mover() }, self)
    game.onCollideDo(self, { otro => otro.recibirImpacto(self) })
  }

  method mover() {
    position = position.right(1)
    if (position.x() >= game.width()) {
      self.morir()
    }
  }

  // efecto sobre el zombie que impactó (las subclases pueden agregar efectos)
  method impactar(zombie) {
    zombie.recibirDanio(self.danio())
  }

  // dos bolitas en la misma celda no se afectan
  method recibirImpacto(otraBolita) {}

  method morir() {
    if (viva) {
      viva = false
      jardin.eliminarTik(idTik)
      jardin.eliminarProyectil(self)
    }
  }
}

class BolitaHielo inherits Bolita {
  override method nombre() = "guisanteDeHielo"

  override method impactar(zombie) {
    super(zombie)
    zombie.ralentizar()
  }
}
