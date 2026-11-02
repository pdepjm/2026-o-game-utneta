import wollok.game.*
import jardin.*
import juego.*
import soles.*
import reloj.*



class Zombie {
  var property position
  const property nombre         
  var vida
  const msPorPaso               
  var ralentizacion = sinRalentizar
  var vivo = true
  const danio                   
  const tarea = new Tarea(milisegundos = msPorPaso, accion = { self.mover() })

  method image() = ralentizacion.imagen(nombre)   
  method carril() = position.y()
  method estaVivo() = vivo

  method iniciar() {
    reloj.agregar(tarea)
  }

  // si tiene una planta adelante se queda comiéndola, si no avanza
  method mover() {
    const adelante = position.left(1)
    if (jardin.hayPlantaEn(adelante)) {
      jardin.plantaEn(adelante).recibirDanio(danio)
    } else {
      position = adelante
      if (position.x() == jardin.columnaCasa()) {     
        juego.perder()
      }
    }
  }

  
  // El zombie reacciona recibiendo el efecto del proyectil; la planta lo ignora.
  method recibirImpacto(proyectil) {
    if (proyectil.estaViva() and vivo) {
      proyectil.impactar(self)
      proyectil.morir()
    }
  }

  method recibirDanio(cantidad) {
    vida -= cantidad
    if (vida <= 0) {
      self.morir()
    }
  }

  method ralentizar() {
    ralentizacion.ralentizar(self)
  }

  // con el estado nuevo, cada paso tarda lo que diga ese estado
  method cambiarRalentizacion(nuevaRalentizacion) {
    ralentizacion = nuevaRalentizacion
    tarea.milisegundos(ralentizacion.msPorPaso(msPorPaso))
  }

  method morir() {
    if (vivo) {
      vivo = false
      tarea.terminar()
      game.removeVisual(self)
      generadorDeZombies.zombieEliminado(self)
    }
  }
}


object sinRalentizar {
  method msPorPaso(msBase) = msBase
  method imagen(nombre) = nombre + ".png"

  method ralentizar(zombie) {
    zombie.cambiarRalentizacion(ralentizado)
  }
}

object ralentizado {
  method msPorPaso(msBase) = msBase * 2
  method imagen(nombre) = nombre + "Congelado.png"

  method ralentizar(zombie) {}   // ya está ralentizado: no se acumula
}


object zombieNormal {
  method crearEn(posicion) = new Zombie(position = posicion, nombre = "zombie", vida = 100, msPorPaso = 2000, danio = 20)
}

// Lento pero con mucha vida
object zombieTanque {
  method crearEn(posicion) = new Zombie(position = posicion, nombre = "zombieTanque", vida = 400, msPorPaso = 3000, danio = 50)
}

// Muy rápido pero con poca vida
object zombieRapido {
  method crearEn(posicion) = new Zombie(position = posicion, nombre = "zombieRapido", vida = 50, msPorPaso = 1000, danio = 10)
}


class Oleada {
  const property cantidad
  const property msEntreZombies
  const tipos

  method tipoAlAzar() = tipos.anyOne()
}


class CartelDeOleada {
  const numero

  const property position = game.at(3, 2)
  method image() = "oleada" + numero + ".png"
}


object generadorDeZombies {
  const property zombiesActivos = []
  const oleadas = [
    new Oleada(cantidad = 6, msEntreZombies = 6000, tipos = [zombieNormal, zombieRapido]),
    new Oleada(cantidad = 8, msEntreZombies = 5000, tipos = [zombieNormal, zombieRapido, zombieTanque]),
    new Oleada(cantidad = 12, msEntreZombies = 2500, tipos = [zombieNormal, zombieRapido, zombieTanque, zombieTanque])
  ]
  const msEntreOleadas = 5000     
  var property numeroDeOleada = 1
  var generados = 0               

  method oleadaActual() = oleadas.get(numeroDeOleada - 1)

  method reiniciar() {
    zombiesActivos.clear()
    numeroDeOleada = 1
  }

  method empezarOleada() {
    generados = 0
    const cartel = new CartelDeOleada(numero = numeroDeOleada)
    game.addVisual(cartel)
    reloj.enUnRato(2500, {
      game.removeVisual(cartel)
      self.sacarZombies()
    })
  }

  method sacarZombies() {
    const oleada = self.oleadaActual()
    self.generar()
    reloj.agregar(new TareaRepetida(milisegundos = oleada.msEntreZombies(), veces = oleada.cantidad() - 1, accion = { self.generar() }))
  }

  method generar() {
    const posicion = game.at(jardin.columnaCalle(), jardin.carriles().anyOne())
    const nuevoZombie = self.oleadaActual().tipoAlAzar().crearEn(posicion)
    zombiesActivos.add(nuevoZombie)
    game.addVisual(nuevoZombie)
    nuevoZombie.iniciar()
    generados += 1
  }

  // Lo usan los lanzadores para decidir si disparan.
  method hayZombiesEnCarril(carril) = zombiesActivos.any({ z => z.carril() == carril })

  method zombieEliminado(unZombie) {
    zombiesActivos.remove(unZombie)
    soles.ganar(25)   // premio por eliminarlo
    if (generados == self.oleadaActual().cantidad() and zombiesActivos.isEmpty()) {
      self.terminarOleada()
    }
  }

  method terminarOleada() {
    if (numeroDeOleada == oleadas.size()) {
      juego.ganar()
    } else {
      numeroDeOleada += 1
      reloj.enUnRato(msEntreOleadas, { self.empezarOleada() })
    }
  }
}
