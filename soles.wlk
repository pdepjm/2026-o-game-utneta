import wollok.game.*
import jardin.*
import reloj.*

// ============================================================
// SOLES: hacen falta para plantar. Se juntan solos con el
// tiempo y también al eliminar zombies.
// ============================================================
object soles {
  const solesAlEmpezar = 150
  const maximo = 999               // el contador tiene 3 dígitos
  var property cantidad = 0
  const digitos = [
    new DigitoDeSoles(columna = 4, divisor = 100),
    new DigitoDeSoles(columna = 5, divisor = 10),
    new DigitoDeSoles(columna = 6, divisor = 1)
  ]

  method iniciar() {
    cantidad = solesAlEmpezar
    game.addVisual(contadorDeSoles)
    digitos.forEach({ digito => game.addVisual(digito) })
    reloj.agregar(new Tarea(milisegundos = 5000, accion = { self.ganar(25) }))   // se juntan con el tiempo
  }

  method ganar(unaCantidad) {
    cantidad = (cantidad + unaCantidad).min(maximo)
  }

  method alcanzan(costo) = costo <= cantidad

  method validarQueAlcancen(costo) {
    if (!self.alcanzan(costo)) {
      throw new NoSePuedePlantar(message = "No te alcanzan los soles", cartel = "avisoSoles.png")
    }
  }

  method gastar(costo) {
    cantidad -= costo
  }
}

// ============================================================
// CONTADOR: la tabla de 3 celdas con el sol y, encima, un
// dígito por celda
// ============================================================
object contadorDeSoles {
  const property position = game.at(4, jardin.filaDelPanel())
  method image() = "contadorDeSoles.png"
}

class DigitoDeSoles {
  const columna
  const divisor      // 100 muestra las centenas, 10 las decenas y 1 las unidades

  const property position = game.at(columna, jardin.filaDelPanel())
  method image() = "numero" + soles.cantidad().div(divisor) % 10 + ".png"
}
