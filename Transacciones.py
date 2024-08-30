from tkinter import messagebox
class Transacciones: 

    def __init__(self, db):
        self.db = db

    def realizar_deposito(self, cuenta_destino, monto, sucursal_ID):
        consulta = "EXEC sp_Realizar_Deposito @CuentaDestinoID=?, @Monto=?, @SucursalID=?"
        try:
            self.db.ejecutar_consulta(consulta, (cuenta_destino, monto, sucursal_ID))
            messagebox.showinfo("Deposito","Depósito realizado con éxito.")
        except Exception as e:
            messagebox.showerror("Error",f"Error al realizar depósito: {e}")

    def realizar_retiro(self, cuenta_origen, monto, sucursal_ID):
        consulta = "EXEC sp_Realizar_Retiro @CuentaOrigenID=?, @Monto=?, @SucursalID=?"
        try:
            self.db.ejecutar_consulta(consulta, (cuenta_origen, monto, sucursal_ID))
            messagebox.showinfo("Retiro","Retiro realizado con éxito.")
        except Exception as e:
            messagebox.showinfo("Error",f"Error al realizar retiro: {e}")

    def realizar_transferencia(self, cuenta_origen, cuenta_destino, monto, sucursal_ID):
        consulta = "EXEC Realizar_Transferencia @CuentaOrigenID=?, @CuentaDestinoID=?, @Monto=?, @SucursalID=?"
        try:
            self.db.ejecutar_consulta(consulta, (cuenta_origen, cuenta_destino, monto, sucursal_ID))
            messagebox.showinfo("Transferencia","Transferencia realizado con éxito.")
        except Exception as e:
            messagebox.showinfo("Error",f"Error al realizar transferencia: {e}")
