from database import BaseDeDatos
from Transacciones import Transacciones
from customtkinter import *
import tkinter as tk
from tkinter import messagebox
from PIL import ImageTk, Image

# Crear una instancia de la base de datos y de las transacciones
db = BaseDeDatos()
transacciones = Transacciones(db)

root = CTk()
root.title("EL BANCO")
root.geometry("300x500+660+200")

"""saldo = 2000

MiUsuario =66666666
Usuario = 5666669999
saldoUsuario = 1000"""

def VentanaDepositar():
    def Ingresar():
        try:
            cuenta_destino = int(Cuenta_Depositar.get()) 
            deposito = float(Depositar.get())
            sucursal_ID = int(Sucursal.get())
            if deposito <= 0:
                messagebox.showerror(title="ERROR", message="El monto debe ser mayor que cero.")
                return
            transacciones.realizar_deposito(cuenta_destino, deposito, sucursal_ID)
            messagebox.showinfo(title="DEPÓSITO", message=f"Sus ${deposito:.2f} fueron depositados.")
        except ValueError:
            messagebox.showerror(title="ERROR", message="Cantidad no válida")

    root2 = CTkToplevel(root)
    root2.title("Depósitos")
    root2.geometry("300x500+660+200")
    root.iconify()

    Etiqueta_CuentaDeposito = CTkLabel(root2, text="ID de la Cuenta a Depositar", font=("Arial", 14))
    Etiqueta_CuentaDeposito.pack(pady=20)
    Cuenta_Depositar = CTkEntry(root2)
    Cuenta_Depositar.pack(pady=20)

    Etiqueta2 = CTkLabel(root2, text="Cantidad a Depositar", font=("Arial", 14))
    Etiqueta2.pack(pady=20)
    Depositar = CTkEntry(root2)
    Depositar.pack(pady=20)

    Etiqueta_Sucursal = CTkLabel(root2, text="ID de la Sucursal", font=("Arial", 14))
    Etiqueta_Sucursal.pack(pady=20)
    Sucursal = CTkEntry(root2)
    Sucursal.pack(pady=20)


    BotonIngresar = CTkButton(root2, text="INGRESAR DEPOSITO", font=("Arial", 14), command=Ingresar)
    BotonIngresar.pack(pady=20)

def VentanaRetirar():
    def Ingresar():
        try:
            cuenta_origen = int(Cuenta_Retiro.get())
            sucursal_ID = int(Sucursal.get())
            retiro = float(Retiro.get())
            if retiro <= 0:
                messagebox.showerror(title="ERROR", message="El monto debe ser mayor que cero.")
                return
            transacciones.realizar_retiro(cuenta_origen, retiro, sucursal_ID)
            messagebox.showinfo(title="RETIRO", message=f"Ha retirado ${retiro:.2f}.")
        except ValueError:
            messagebox.showerror(title="ERROR", message="Cantidad no válida")

    root3 = CTkToplevel(root)
    root3.title("Retiros")
    root3.geometry("300x500+660+200")
    root.iconify()

    Etiqueta_CuentaRetiro = CTkLabel(root3, text="ID de la Cuenta a Retirar", font=("Arial", 14))
    Etiqueta_CuentaRetiro.pack(pady=20)
    Cuenta_Retiro = CTkEntry(root3)
    Cuenta_Retiro.pack(pady=20)

    Etiqueta3 = CTkLabel(root3, text="Cantidad a Retirar", font=("Arial", 14))
    Etiqueta3.pack(pady=20)
    Retiro = CTkEntry(root3)
    Retiro.pack(pady=20)

    Etiqueta_Sucursal = CTkLabel(root3, text="ID de la Sucursal", font=("Arial", 14))
    Etiqueta_Sucursal.pack(pady=20)
    Sucursal = CTkEntry(root3)
    Sucursal.pack(pady=20)

    BotonIngresar = CTkButton(root3, text="INGRESAR", font=("Arial", 14), command=Ingresar)
    BotonIngresar.pack(pady=20)

def VentanaTransferencia():
    def Ingresar():
        try:
            cuenta_origen = int(MiCuenta.get())
            cuenta_destino = int(Transferencia.get())
            monto = float(MontoTransferencia.get())
            sucursal_ID = int(Sucursal.get())
            if monto <= 0:
                messagebox.showerror(title="ERROR", message="El monto debe ser mayor que cero.")
                return
              # Asume una sucursal específica
            transacciones.realizar_transferencia(cuenta_origen, cuenta_destino, monto, sucursal_ID)
            messagebox.showinfo(title="TRANSFERENCIA", message=f"Se han transferido ${monto:.2f}.")
        except ValueError:
            messagebox.showerror(title="ERROR", message="Datos no válidos")

    root4 = CTkToplevel(root)
    root4.title("Transferencias")
    root4.geometry("300x630+660+130")
    root.iconify()
    EtiquetaMonto = CTkLabel(root4, text="Cantidad a Transferir", font=("Arial", 14))
    EtiquetaMonto.pack(pady=20)
    MontoTransferencia = CTkEntry(root4)
    MontoTransferencia.pack(pady=20)

    EtiquetaCuentaOrigen = CTkLabel(root4, text="Mi cuenta", font=("Arial", 14))
    EtiquetaCuentaOrigen.pack(pady=20)
    MiCuenta = CTkEntry(root4)
    MiCuenta.pack(pady=20)

    EtiquetaCuentaDestino = CTkLabel(root4, text="Cuenta a Transferir", font=("Arial", 14))
    EtiquetaCuentaDestino.pack(pady=20)
    Transferencia = CTkEntry(root4)
    Transferencia.pack(pady=20)

    EtiquetaSucursal = CTkLabel(root4, text="Ingrese el ID de su Sucursal", font=("Arial", 14))
    EtiquetaSucursal.pack(pady=20)
    Sucursal = CTkEntry(root4)
    Sucursal.pack(pady=20)

    BotonIngresar = CTkButton(root4, text="REALIZAR TRANSFERENCIA", font=("Arial", 14), command=Ingresar)
    BotonIngresar.pack(pady=20)

# Frontend Main
FstAlien = ImageTk.PhotoImage(Image.open("bank.png"))
FstAlLabel = tk.Label(image=FstAlien)
FstAlLabel.pack()
Etiqueta = CTkLabel(root, text="MI BANCO", font=("Arial", 18))
Etiqueta.pack(pady=10)
Etiqueta2 = CTkLabel(root, text="¿Qué desea hacer hoy?", font=("Arial", 14))
Etiqueta2.pack(pady=10)

Deposito = CTkButton(root, text='DEPÓSITO', command=VentanaDepositar, font=("Arial", 16))
Deposito.pack(pady=20)
Retiro = CTkButton(root, text='RETIRO', font=("Arial", 16), command=VentanaRetirar)
Retiro.pack(pady=20)
Transferencia = CTkButton(root, text='TRANSFERENCIA', font=("Arial", 16), command=VentanaTransferencia)
Transferencia.pack(pady=20)
Salir = CTkButton(root, text='SALIR', font=("Arial", 16))
Salir.pack(pady=20)

root.mainloop()




